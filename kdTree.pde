float traversalCost = 1;
float intersectionCost = 80;

//TODO msati3: Cleanup memory usage stuff from all these data-structures
class KDTreeNode
{
  float m_splitPlane;
  int m_child1;
  int m_child2AndType;
  private ArrayList<Integer> m_indices;

  KDTreeNode( float splitPlane, int type )
  {
    m_splitPlane = splitPlane;
    m_child1 = -1;
    m_child2AndType = type;
    m_indices = null;
  }

  KDTreeNode( ArrayList<Integer> indices, int type )
  {
    m_indices = indices;
    m_child1 = -1;
    m_child2AndType = type;
    m_splitPlane = -1;
  }

  public void setChild( boolean fLeft, int child )
  {
    if ( fLeft )
    {
      m_child1 = child;
    }
    else
    {
      m_child2AndType |= (child<<2);
    }
  }

  public int getType()
  {
    return m_child2AndType & 0x3;
  }

  public int child1()
  {
    return m_child1;
  }

  public int child2()
  {
    return m_child2AndType>>2;
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

class SplitResult
{
  private ArrayList<Integer> m_indicesLeft;
  private ArrayList<Integer> m_indicesRight;
  private Box m_boxLeft;
  private Box m_boxRight;
  private float m_splitPlane;
  private int m_splitPlaneDirection;

  private int m_parent;
  private boolean m_fLeftChild;
  
  SplitResult( ArrayList<Integer> indicesLeft, ArrayList<Integer> indicesRight, Box boxLeft, Box boxRight, float splitPlane, int splitPlaneDirection )
  {
    m_indicesLeft = indicesLeft;
    m_indicesRight = indicesRight;
    m_boxLeft = boxLeft;
    m_boxRight = boxRight;
    m_splitPlane = splitPlane;
    m_splitPlaneDirection = splitPlaneDirection;
    
    //Parameters for retrospectively pointing parent to its children
    m_parent = -1;
    m_fLeftChild = false;
    //print("Best split " + m_splitPlaneDirection + " " + m_splitPlane + "\n");
  }
  
  public void setParentAndChildFlag( int parent, boolean fLeftChild ) 
  {
    m_parent = parent; 
    m_fLeftChild = fLeftChild;
  }
 
  public float splitPlane() { return m_splitPlane; }
  public int splitPlaneDirection() { return m_splitPlaneDirection; }
  public Box boxLeft() { return m_boxLeft; }
  public Box boxRight() { return m_boxRight; }
  public ArrayList<Integer> indicesLeft() { return m_indicesLeft; }
  public ArrayList<Integer> indicesRight() { return m_indicesRight; }

  public int parent() { return m_parent; }
  public boolean fLeftChild() { return m_fLeftChild; }
}

//This maintains a queue of results that are produced by the KDTreeSplitCreatorTask threads. The kdtree creator reads these and spawns off further SplitCreatorTasks
class SplitResultQueue
{
  private ArrayList<SplitResult> m_results;
  private int m_consumptionIndex;
  
  SplitResultQueue()
  {
    m_results = new ArrayList<SplitResult>();
    m_consumptionIndex = 0;
  }
  
  //Multiple producing threads can write to this
  public synchronized void onProduce( SplitResult result)
  {
    m_results.add( result );
    this.notifyAll();
  }
  
  //This is just to be used by the single consuming thread
  //Is is the callers responsibility to ensure that this is not called when no more creator threads exist
  public synchronized SplitResult onConsume()
  {
    if ( m_consumptionIndex == m_results.size() )
    {
      try
      {
        this.notifyAll();
        this.wait();
      }
      catch (InterruptedException ex)
      {
        print("Caught interrupted exception in on consume!!\n");
      }
    }
    //Wait until some thread produces
    SplitResult result = m_results.get(m_consumptionIndex);
    m_consumptionIndex++;
    return result;
  }
}

class KDTreeSplitCreatorTask implements Task
{
  private ArrayList<Integer> m_indices;
  private Box m_box;
  private SplitResultQueue m_queue; 
  private KDTree m_tree;

  //To populate parent's points when this Task is done 
  private int m_parent;
  private boolean m_fLeftChild;
  
  KDTreeSplitCreatorTask( KDTree tree, ArrayList<Integer> indices, Box box, SplitResultQueue queue, int parent, boolean fLeftChild )
  {
    m_indices = indices;
    m_box = box;
    m_queue = queue;
    m_parent = parent;
    m_fLeftChild = fLeftChild;
    m_tree = tree;
  }
  
  public void run()
  {
    SplitResult result = m_tree.createSingleSplitUsingSubdivision( m_indices, m_box );
    result.setParentAndChildFlag( m_parent, m_fLeftChild );
    m_queue.onProduce( result );
  }
}

//Facilitates Parallel creation of KD-Tree
class KDTreeCreator
{
  private KDTree m_tree;
  private ExecutorService m_pool;
  private ArrayList<KDTreeNode> m_nodes;
  private SplitResultQueue m_queue;
    
  KDTreeCreator( ArrayList<LightedPrimitive> objects )
  {
    m_tree = new KDTree( objects );
    int cores = Runtime.getRuntime().availableProcessors();
    m_pool = Executors.newFixedThreadPool(3*cores);
    m_queue = new SplitResultQueue();
    m_nodes = new ArrayList<KDTreeNode>();
  }
  
  public KDTree create()
  {
    int threadsSpawned = 0;
    int threadsReturned = 0;

    ArrayList<Integer> indices = new ArrayList<Integer>();
    for (int i = 0; i < m_tree.getNumObjects(); i++)
    {
      indices.add(i);
    }
    Box boundingBox = cloneBox( m_tree.getBoundingBox() );

    KDTreeSplitCreatorTask task = new KDTreeSplitCreatorTask( m_tree, indices, boundingBox, m_queue, -1, false );
    Thread t = new Thread(task);
    m_pool.submit(t);
    threadsSpawned++;

    while ( threadsReturned != threadsSpawned )
    {
      SplitResult result = m_queue.onConsume();
      threadsReturned++;
      if ( result.splitPlaneDirection() != -1 )
      {
        KDTreeNode newNode = new KDTreeNode( result.splitPlane(), result.splitPlaneDirection() );
        m_nodes.add( newNode );
        int index = m_nodes.size() - 1;
        if ( result.parent() != -1 )
        {
          m_nodes.get( result.parent() ).setChild( result.fLeftChild(), index );
        }

        if ( DEBUG && DEBUG_MODE >= VERBOSE )
        {
          print("Adding plane " + result.splitPlane() + " direction " + result.splitPlaneDirection() + " " + result.indicesLeft() + " " + result.indicesRight() + "\n");
        }
 
        KDTreeSplitCreatorTask taskLeft = new KDTreeSplitCreatorTask( m_tree, result.indicesLeft(), result.boxLeft(), m_queue, index, true );
        Thread taskLeftThread = new Thread(taskLeft);
        m_pool.submit(taskLeftThread);
        threadsSpawned++;
      
        KDTreeSplitCreatorTask taskRight = new KDTreeSplitCreatorTask( m_tree, result.indicesRight(), result.boxRight(), m_queue, index, false );
        Thread taskRightThread = new Thread(taskRight);
        m_pool.submit(taskRightThread);
        threadsSpawned++;
      }
      else
      {
        m_nodes.add( new KDTreeNode( result.indicesLeft(), 3 ) );
        int index = m_nodes.size() - 1;
        if ( result.parent() != -1 )
        {
          m_nodes.get( result.parent() ).setChild( result.fLeftChild(), index );
        }
        if ( DEBUG && DEBUG_MODE >= VERBOSE )
        {
          print("Adding leaf with children " + m_nodes.get( m_nodes.size() - 1 ).getIndices() + "\n");
        }
      }
    }
    m_pool.shutdown();
    try
    {
      m_pool.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
    } catch ( InterruptedException ex )
    {
      print("Exception occurred while shutting down thread pool! KDTreeCreator::create render!");
    }   
    m_tree.setNodes( m_nodes );
    return m_tree;
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
    m_nodes = nodes;
  }

  private float findCost( float probLeft, float probRight, int numLeft, int numRight )
  {
    float factor = (numLeft == 0 || numRight == 0)? 0.8 : 1;
    return factor * (traversalCost + (probLeft*numLeft + probRight*numRight) * intersectionCost);
  }
  
  //Spatial subdivision approach. Currently http://electronic-blue.wdfiles.com/local--files/research%3Agpurt/WK06.pdf.
  //TODO msati3: Implement the approach mentioned in http://www.cs.utexas.edu/~whunt/papers/fast-kd-construction-RT06.pdf
  //This has to be thread safe. Is is called by each KDTreeSplitCreator task
  public SplitResult createSingleSplitUsingSubdivision( ArrayList<Integer> indices, Box box )
  {
    SplitResult result = null;
    if ( DEBUG && DEBUG_MODE >= VERBOSE )
    {
      print("Number of objects " + indices.size() + "\n");
    }
    float totalArea = box.surfaceArea();
    float minSplitPlane = 0;
    int minSplitPlaneDirection = -1;

    BoxSplitResult minSplitResult = null;

    float costCurrent = intersectionCost * indices.size();
    float minCost = Float.MAX_VALUE;
    
    ArrayList<Integer> leftIndices = null;
    ArrayList<Integer> rightIndices = null;
    ArrayList<Integer> minLeftIndices = null;
    ArrayList<Integer> minRightIndices = null;
    
    int numSamples = 8; //This is the maximum number of samples we consider for deciding split along each direction
    //Find best split pane

    float maxRange = 0;
    int maxAxis = 0;

    int numLeft = 0;
    int numRight = 0;

    for (int dim = 0; dim < 3; dim++)
    {
      float lowerRange = box.getPlaneForFace(dim<<1);
      float higherRange = box.getPlaneForFace((dim<<1)+1);
      if ( higherRange - lowerRange > maxRange )
      {
        maxRange = higherRange - lowerRange;
        maxAxis = dim;
      }
    }
    
    float lowerRange = box.getPlaneForFace(maxAxis<<1);
    float higherRange = box.getPlaneForFace((maxAxis<<1)+1);  
    float proposedPlane = higherRange/2.0 + lowerRange/2.0;
    int numTries = 0;
    while ( (higherRange - lowerRange) > c_epsilon && numTries++ < numSamples )
    {
      BoxSplitResult s = box.split( proposedPlane, maxAxis );
      float probLeft = s.box1.surfaceArea() / box.surfaceArea();
      float probRight = s.box2.surfaceArea() / box.surfaceArea();

      if ( DEBUG && DEBUG_MODE >= LOW )
      {
        if ( s.box1.surfaceArea() >= box.surfaceArea() )
        {
          print(proposedPlane + " " + maxAxis + " " + higherRange + " " + lowerRange + "\n");
          print("Box Split1 Split2:");
          box.debugPrint();
          s.box1.debugPrint();
          s.box2.debugPrint();
        }
      }
      leftIndices = new ArrayList<Integer>();
      rightIndices = new ArrayList<Integer>();
      for (int i = 0; i < indices.size(); i++)
      {
        int index = indices.get(i);
        float leftFace = m_objects.get( index ).getBoundingBox().getPlaneForFace(maxAxis<<1);
        float rightFace = m_objects.get( index ).getBoundingBox().getPlaneForFace((maxAxis<<1)+1);
        
        if ( rightFace < proposedPlane )
        {
          leftIndices.add( index );
        }
        else if ( leftFace > proposedPlane )
        {
          rightIndices.add( index );
        }
        else
        {
          rightIndices.add( index );
          leftIndices.add( index );
        }
      }

      if ( !( (compare( probLeft, 1 ) ) || (compare( probRight, 1 ) ) ) )
      {
        numLeft = leftIndices.size();
        numRight = rightIndices.size();
        float cost = findCost( probLeft, probRight, numLeft, numRight );
        if ( cost < minCost && cost < costCurrent )
        {
          minLeftIndices = leftIndices;
          minRightIndices = rightIndices;
          minCost = cost;
          minSplitPlaneDirection = maxAxis;
          minSplitPlane = proposedPlane;
          minSplitResult = s;

          if ( numLeft < numRight )
          {
            lowerRange = proposedPlane;
            proposedPlane = higherRange/2 + lowerRange/2;
          }
          else
          {
            higherRange = proposedPlane;
            proposedPlane = higherRange/2 + lowerRange/2;
          }
        }
      }
    }
    if ( minSplitPlaneDirection != -1 )
    {
      return new SplitResult( minLeftIndices, minRightIndices, minSplitResult.box1, minSplitResult.box2, minSplitPlane, minSplitPlaneDirection );
    }
    return new SplitResult( indices, null, box, null, minSplitPlane, minSplitPlaneDirection );
  }

  //Trivial sorting implementation right now. TODO msati3: implement the one mentioned at http://www.eng.utah.edu/~cs6965/papers/kdtree.pdf
  //This has to be thread safe. Is is called by each KDTreeSplitCreator task
  public SplitResult createSingleSplitUsingSort( ArrayList<Integer> indices, Box box )
  {
    SplitResult result = null;
    if ( DEBUG && DEBUG_MODE >= VERBOSE )
    {
      print("Number of objects " + indices.size() + "\n");
    }
    float totalArea = box.surfaceArea();
    float minSplitPlane = 0;
    int minSplitPlaneDirection = -1;

    BoxSplitResult minSplitResult = null;

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
    if ( minSplitPlaneDirection != -1 )
    {
      return new SplitResult( minLeftIndices, minRightIndices, minSplitResult.box1, minSplitResult.box2, minSplitPlane, minSplitPlaneDirection );
    }
    return new SplitResult( indices, null, box, null, minSplitPlane, minSplitPlaneDirection );
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }
  
  public int getNumObjects()
  {
    return m_objects.size();
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
      print( m_nodes.get(nodeIndex).child1() + " " );
      printTree( m_nodes.get(nodeIndex).child1() );
      printTree( m_nodes.get(nodeIndex).child2() );
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
      print( nodeIndex + " " + tSplit + " " + tMin + " " + tMax + " \n");
      ray.debugPrint();
      printTree( nodeIndex );
      print("\n");
    }

    if ( ray.getDirection().get(axis) >= 0 )
    {
      nearChild = m_nodes.get(nodeIndex).child1();
      farChild = m_nodes.get(nodeIndex).child2();
    }
    else
    {
      nearChild = m_nodes.get(nodeIndex).child2();
      farChild = m_nodes.get(nodeIndex).child1();
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
      nearChild = m_nodes.get(nodeIndex).child1();
      farChild = m_nodes.get(nodeIndex).child2();
    }
    else
    {
      nearChild = m_nodes.get(nodeIndex).child2();
      farChild = m_nodes.get(nodeIndex).child1();
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
    if ( tExtents != null )
    {
      intersectionInfo = getIntersectionInfoRecursive( 0, ray, tExtents[0] - c_epsilon, tExtents[1] + c_epsilon);
    }
    return intersectionInfo;
  }
}

