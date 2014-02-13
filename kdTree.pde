float traversalCost = 1;
float intersectionCost = 80;

class KDTreeNode
{
  float m_splitPlane;
  int m_otherChildAndType;
  private ArrayList<Integer> m_indices;

  KDTreeNode( float splitPlane, int type )
  {
    m_splitPlane = splitPlane;
    m_otherChildAndType = type;
    m_indices = null;
  }

  KDTreeNode( ArrayList<Integer> indices, int type )
  {
    m_indices = indices;
    m_otherChildAndType = type;
    m_splitPlane = -1;
  }

  public void setOtherChild( int otherChild )
  {
    m_otherChildAndType |= otherChild;
  }

  public int getType()
  {
    return m_otherChildAndType & 0x3;
  }

  public int getOtherChild()
  {
    return m_otherChildAndType>>2;
  }

  public ArrayList<Integer> getIndices()
  {
    return m_indices;
  }

  public float getSplitPlane()
  {
    return m_splitPlane;
  }
}

class SweepEvent
{
  private Integer m_index;
  private float m_planeLocation;
  private boolean m_fStartFace;
  
  SweepEvent( Integer index, float planeLocation, boolean fStartFace )
  {
    m_index = index;
    m_planeLocation = planeLocation;
    m_fStartFace = fStartFace;
  }
  
  float planeLocation() { return m_planeLocation; }
  boolean fStartFace() { return m_fStartFace; }
  Integer index() { return m_index; }
}

class SweepEventComparator implements Comparator<SweepEvent> 
{
  public int compare(SweepEvent e1, SweepEvent e2) 
  {
    if ( e1.planeLocation() > e2.planeLocation() )
    {
      return 1;
    }
    else if ( e1.planeLocation() < e2.planeLocation() )
    {
      return -1;
    }
    return 0;
  }
}

class SingleSplitResult
{
  private ArrayList<Integer> m_indicesLeft;
  private ArrayList<Integer> m_indicesRight;
  private Box m_boxLeft;
  private Box m_boxRight;
  private float m_splitPlane;
  private int m_splitPlaneDirection;
  
  SingleSplitResult( ArrayList<Integer> indicesLeft, ArrayList<Integer> indicesRight, Box boxLeft, Box boxRight, float splitPlane, int splitPlaneDirection )
  {
    m_indicesLeft = indicesLeft;
    m_indicesRight = indicesRight;
    m_boxLeft = boxLeft;
    m_boxRight = boxRight;
    m_splitPlane = splitPlane;
    m_splitPlaneDirection = splitPlaneDirection;
  }
  
  public float splitPlane() { return m_splitPlane; }
  public int splitPlaneDirection() { return m_splitPlaneDirection; }
  public Box boxLeft() { return m_boxLeft; }
  public Box boxRight() { return m_boxRight; }
  public ArrayList<Integer> indicesLeft() { return m_indicesLeft; }
  public ArrayList<?Integer> indicesRight() { return m_indicesRight; }
}

//This maintains a queue of results that are produced by the KDTreeSplitCreatorTask threads. The kdtree creator reads these and spawns off further SplitCreatorTasks
class SingleSplitResultQueue
{
  private Queue<SingleSplitResult> m_results;
  
  SharedResult()
  {
    m_results = new ArrayList<SingleSplitResult>();
  }
  
  public synchronized void onProduce( SingleSplitResult result)
  {
    m_results.add( result );
    this.notifyAll();
  }
  
  public synchronized SingleSplitResult onConsume()
  {
    return m_results.remove();
  }
}

class KDTreeSplitCreatorTask implements Task
{
  private ArrayList<Integer> m_indices;
  private Box m_box;
  private SingleSplitResultQueue m_queue; 
  
  KDTreeSplitCreatorTask( ArrayList<Integer> indices, Box box, SingleSplitResultQueue queue )
  {
    m_indices = indices;
    m_box = box;
    m_queue = queue;
  }
  
  public void run()
  {
    SingleSplitResult result = m_input.tree().createSingleSplit( m_indices, m_box );
    m_queue.add( result );
  }
}

//Paraller creation of KD-Tree
class KDTreeCreator
{
  private KDTree m_tree;
  private ExecutorService m_pool;
  private ArrayList<KDTreeNode> m_nodes;
  private SingleSplitResultQueue m_queue; 
    
  KDTreeCreator( ArrayList<LightedPrimitive> objects )
  {
    m_tree = new KDTree( objects );
    int cores = Runtime.getRuntime().availableProcessors();
    m_pool = Executors.newFixedThreadPool(2*cores);
    m_queue = new SingleSplitResultQueue();

    ArrayList<Integer> indices = new ArrayList<Integer>();
    for (int i = 0; i < objects.size(); i++)
    {
      indices.add(i);
    }
    Box boundingBox = cloneBox( m_tree.getBoundingBox() );

    KDTreeSplitCreatorTask task = new KDTreeSplitCreatorTask( indices, boundingBox, m_queue );
    Thread t = new Thread(task);
    m_pool.submit(t);
    onSplitResultAvailable();
  }
  
  public void onSplitResultAvailable()
  {
    SingleSplitResult result = m_queue.onConsume();
    if ( result.splitPlaneDirection() != -1 )
    {
      m_nodes.add( new KDTreeNode( result.splitPlane(), result.splitPlaneDirection() );
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        print("Adding plane " + result.splitPlane() + " direction " + result.splitPlaneDirection() + " " + result.indicesLeft() + " " + result.indicesRight() + "\n");
      }

      KDTreeSplitCreatorTask taskLeft = new KDTreeSplitCreatorTask( result.indicesLeft(), result.boxLeft(), m_queue );
      Thread taskLeftThread = new Thread(taskLeft);
      m_pool.submit(taskLeftThread);
      
      KDTreeSplitCreatorTask taskRight = new KDTreeSplitCreatorTask( result.indicesRight(), result.boxRight(), m_queue );
      Thread taskRightThread = new Thread(taskRight);
      m_pool.submit(taskRightThread);

      int otherChild = right<<2;
      m_nodes.get(indexAdded).setOtherChild( otherChild );
      return indexAdded;
    }
    else
    {
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        print("Adding leaf with children " + indices + "\n");
      }
      m_nodes.add( new KDTreeNode( indices, 3 ) );
      return m_nodes.size() - 1;
    }
  }
}

//Start with naive
class KDTree implements Primitive
{
  private Box m_boundingBox;
  private ArrayList<LightedPrimitive> m_objects;
  private ArrayList<KDTreeNode> m_nodes;

  KDTree( ArrayList<LightedPrimitive> objects )
  {
    m_objects = objects;

    //Init with first bounding box
    m_boundingBox = cloneBox( objects.get(0).getBoundingBox() );
    for (int i = 1; i < objects.size(); i++)
    {
      m_boundingBox.grow( objects.get(i).getBoundingBox() );
    }
    m_boundingBox.setSurfaceArea();
  }
  
  void setNodes( ArrayList<KDTreeNode> nodes )
  {
    m_nodes = m_nodes;
  }

  private float findCost( float probLeft, float probRight, int numLeft, int numRight )
  {
    float factor = (numLeft == 0 || numRight == 0)? 0.8 : 1;
    return factor * (traversalCost + (probLeft*numLeft + probRight*numRight) * intersectionCost);
  }

  //Trivial sorting implementation right now
  private SingleSplitResult createSingleSplit( ArrayList<Integer> indices, Box box )
  {
    SingleSplitResult result = null;
    if ( DEBUG && DEBUG_MODE >= VERBOSE )
    {
      print("Number of objects " + indices.size() + "\n");
    }
    float totalArea = box.surfaceArea();
    float minSplitPlane = 0;
    int minSplitPlaneDirection = -1;

    SplitResult minSplitResult = null;

    float costCurrent = intersectionCost * indices.size();
    float minCost = Float.MAX_VALUE;
    
    ArrayList<SweepEvent>[] planeLocations = (ArrayList<SweepEvent>[])new ArrayList[3];
    ArrayList<Integer>[] leftIndices = (ArrayList<Integer>[])new ArrayList[3];
    ArrayList<Integer>[] rightIndices = (ArrayList<Integer>[])new ArrayList[3];
    ArrayList<Integer> minLeftIndices = null;
    ArrayList<Integer> minRightIndices = null;
    
    //Sort according to dimension
    for (int dim = 0; dim < 3; dim++)
    {
      planeLocations[dim] = new ArrayList<SweepEvent>();
      leftIndices[dim] = new ArrayList<Integer>();
      rightIndices[dim] = new ArrayList<Integer>();
      for ( int i = 0; i < indices.size(); i++ )
      {
        planeLocations[dim].add( new SweepEvent( indices.get(i), m_objects.get( indices.get(i) ).getBoundingBox().getPlaneForFace(dim<<1), true ) );
        planeLocations[dim].add( new SweepEvent( indices.get(i), m_objects.get( indices.get(i) ).getBoundingBox().getPlaneForFace((dim<<1)+1), false ) );
        rightIndices[dim].add(indices.get(i));
      }
      Collections.sort(planeLocations[dim], new SweepEventComparator());
    }
    
    //Find best split pane
    for (int dim = 0; dim < 3; dim++)
    {
      int numLeft = 0;
      int numRight = indices.size();

      for (int i = 0; i < planeLocations[dim].size(); i++)
      {
        float proposedPlane = planeLocations[dim].get(i).planeLocation();
        Integer objectIndex = planeLocations[dim].get(i).index();
        int face = planeLocations[dim].get(i).fStartFace() ? (dim<<1) : (dim<<1)+1;
        
        BoxSplitResult s = box.split( m_objects.get(objectIndex).getBoundingBox(), face );
        float probLeft = s.box1.surfaceArea() / box.surfaceArea();
        float probRight = s.box2.surfaceArea() / box.surfaceArea();
        
        int farthestAdvance = i;
        while ( farthestAdvance < planeLocations[dim].size() && ( planeLocations[dim].get(farthestAdvance).planeLocation() <= proposedPlane ) )
        {
          if ( planeLocations[dim].get(farthestAdvance).fStartFace() )
          {
            numLeft++;
            leftIndices[dim].add(planeLocations[dim].get(farthestAdvance).index());
          }
          else
          {
            numRight--;
            rightIndices[dim].remove(planeLocations[dim].get(farthestAdvance).index());
          }
          farthestAdvance++;
        }
        i = farthestAdvance - 1;
        
        if ( DEBUG && DEBUG_MODE >= LOW )
        {
          if ( s.box1.surfaceArea() > box.surfaceArea() )
          {
            print("Box Split1 Split2:");
            box.debugPrint();
            s.box1.debugPrint();
            s.box2.debugPrint();
          }
        }
        if ( !( (compare( probLeft, 1 ) ) || (compare( probRight, 1 ) ) ) )
        {
          float cost = findCost( probLeft, probRight, numLeft, numRight );
          if ( cost < minCost && cost < costCurrent )
          {
            minLeftIndices = new ArrayList(leftIndices[dim]);
            minRightIndices = new ArrayList(rightIndices[dim]);
            minCost = cost;
            minSplitPlaneDirection = dim;
            minSplitPlane = proposedPlane;
            minSplitResult = s;
          }
        }
      }
    }
    return new SingleSplitResult( minLeftIndices, minRightIndices, minSplitResult.box1, minSplitResult.box2, minSplitPlane, minSplitPlaneDirection );
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }

  private IntersectionInfo getIntersectionInfoLeaf( Integer nodeIndex, Ray ray, float tMin, float tMax )
  {
    ArrayList<Integer> indices = m_nodes.get(nodeIndex).getIndices();
    IntersectionInfo info = null;
    IntersectionInfo localInfo = null;
    for ( int i = 0; i < indices.size(); i++ )
    {
      localInfo = m_objects.get( indices.get(i) ).getIntersectionInfo( ray, tMin, tMax );
      if ( localInfo != null && ( info == null || localInfo.t() < info.t() ) )
      {
        info = localInfo;
      }
    }
    return info;
  }

  private boolean intersectsLeaf( Integer nodeIndex, Ray ray, float tMin, float tMax )
  {
    ArrayList<Integer> indices = m_nodes.get(nodeIndex).getIndices();
    boolean intersect = false;
    for ( int i = 0; i < indices.size(); i++ )
    {
      intersect = m_objects.get( indices.get(i) ).intersects( ray, tMin, tMax );
      if ( intersect == true )
      {
        break;
      }
    }
    return intersect;
  } 

  private void printTree( int nodeIndex )
  {
    int axis = m_nodes.get(nodeIndex).getType();
    if ( axis == 3)
    {
      print( m_nodes.get(nodeIndex).getIndices() );
    }
    else
    {
      printTree( nodeIndex + 1 );
      printTree( m_nodes.get(nodeIndex).getOtherChild() );
    }
  }

  private IntersectionInfo getIntersectionInfoRecursive( Integer nodeIndex, Ray ray, float tMin, float tMax )
  {
    int axis = m_nodes.get(nodeIndex).getType();
    if ( axis == 3 )
    {
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        print("Traversal " + m_nodes.get(nodeIndex).getIndices() + "\n");
      }
      IntersectionInfo ret = getIntersectionInfoLeaf( nodeIndex, ray, tMin, tMax );
      return ret;
    }

    float splitPos = m_nodes.get(nodeIndex).getSplitPlane();
    float invDirection = 1/ray.getDirection().get(axis);
    float tSplit = (splitPos - ray.getOrigin().get(axis))*invDirection;
    int nearChild = 0;
    int farChild = 0;

    if ( DEBUG && DEBUG_MODE >= VERBOSE )
    {
      print( nodeIndex + " " + tSplit + " " + tMin + " " + tMax  + " \n");
      printTree( nodeIndex );
      print("\n");
    }

    if ( ray.getDirection().get(axis) >= 0 )
    {
      nearChild = nodeIndex + 1;
      farChild = m_nodes.get(nodeIndex).getOtherChild();
    }
    else
    {
      nearChild = m_nodes.get(nodeIndex).getOtherChild();
      farChild = nodeIndex + 1;
    }

    if ( tSplit < tMin && (tSplit == tSplit) )
    {
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        printTree( farChild );
        print("\n");
      }
      IntersectionInfo ret = getIntersectionInfoRecursive( farChild, ray, tMin, tMax );
      //print(ret);
      return ret;
    }
    else if ( tSplit > tMax && (tSplit == tSplit) )
    {
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        printTree( nearChild );
        print("\n");
      }
      IntersectionInfo ret = getIntersectionInfoRecursive( nearChild, ray, tMin, tMax );
      //print(ret);
      return ret;
    }
    else
    {
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        printTree( nodeIndex );
        print("\n");
      }
      IntersectionInfo info = getIntersectionInfoRecursive( nearChild, ray, tMin, tSplit + c_epsilon );
      if ( info != null )
      {
        //print(info);
        return info;
      }
      IntersectionInfo ret = getIntersectionInfoRecursive( farChild, ray, tSplit - c_epsilon, tMax );
      //print(ret);
      return ret;
    }
  }

  private boolean intersectsRecursive( Integer nodeIndex, Ray ray, float tMin, float tMax )
  {
    int axis = m_nodes.get(nodeIndex).getType();
    if ( axis == 3 )
    {
      return intersectsLeaf( nodeIndex, ray, tMin, tMax );
    }

    float splitPos = m_nodes.get(nodeIndex).getSplitPlane();
    float invDirection = 1/ray.getDirection().get(axis);
    float tSplit = (splitPos - ray.getOrigin().get(axis)) * invDirection;
    int nearChild = 0;
    int farChild = 0;
    if ( ray.getDirection().get(axis) >= 0 )
    {
      nearChild = nodeIndex + 1;
      farChild = m_nodes.get(nodeIndex).getOtherChild();
    }
    else
    {
      nearChild = m_nodes.get(nodeIndex).getOtherChild();
      farChild = nodeIndex + 1;
    }

    if ( tSplit < tMin && (tSplit == tSplit) )
    {
      return intersectsRecursive( farChild, ray, tMin, tMax );
    }
    else if ( tSplit > tMax && (tSplit == tSplit) )
    {
      return intersectsRecursive( nearChild, ray, tMin, tMax );
    }
    else
    {
      boolean intersects = intersectsRecursive( nearChild, ray, tMin, tSplit + c_epsilon );
      if ( intersects != false )
      {
        return intersects;
      }
      return intersectsRecursive( farChild, ray, tSplit - c_epsilon, tMax );
    }
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    float[] tExtents = m_boundingBox.getIntersectionExtents( ray );
    boolean intersects = false;
    if ( tExtents != null )
    {
      intersects = intersectsRecursive( 0, ray, tExtents[0], tExtents[1] );
    }
    return intersects;
  }

  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    float[] tExtents = m_boundingBox.getIntersectionExtents( ray );
    IntersectionInfo intersectionInfo = null;
    intersectionInfo = getIntersectionInfoRecursive( 0, ray, tExtents[0] - c_epsilon, tExtents[1] + c_epsilon);
    return intersectionInfo;
  }
}

