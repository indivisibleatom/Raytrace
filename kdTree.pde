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

//Start with naive
class KDTree implements Primitive
{
  private Box m_boundingBox;
  private ArrayList<LightedPrimitive> m_objects;
  private ArrayList<KDTreeNode> m_nodes;

  KDTree()
  {
    m_nodes = new ArrayList<KDTreeNode>();
  }

  private float findCost( float probLeft, float probRight, int numLeft, int numRight )
  {
    float factor = (numLeft == 0 || numRight == 0)? 0.8 : 1;
    return factor * (traversalCost + (probLeft*numLeft + probRight*numRight) * intersectionCost);
  }

  public void create( ArrayList<LightedPrimitive> objects )
  {
    m_objects = objects;
    ArrayList<Integer> indices = new ArrayList<Integer>();

    //Init with first bounding box
    m_boundingBox = cloneBox( objects.get(0).getBoundingBox() );
    indices.add(0);

    for (int i = 1; i < objects.size(); i++)
    {
      indices.add(i);
      m_boundingBox.grow( objects.get(i).getBoundingBox() );
    }
    m_boundingBox.setSurfaceArea();
    if ( DEBUG && DEBUG_MODE >= LOW )
    {
      for (int i = 0; i < objects.size(); i++)
      {
        m_objects.get(i).getBoundingBox().debugPrint();
      }
      m_boundingBox.debugPrint();
    }
    recursiveCreate( indices, m_boundingBox );
    print("Created tree\n");
  }

  //Trivial sorting implementation right now
  private int recursiveCreate( ArrayList<Integer> indices, Box box )
  {
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

      /*if ( dim == 2 )
      {
        print( "Start " + leftIndices[dim] + " " + rightIndices[dim] + "\n");
      }*/
      for (int i = 0; i < planeLocations[dim].size(); i++)
      {
        float proposedPlane = planeLocations[dim].get(i).planeLocation();
        Integer objectIndex = planeLocations[dim].get(i).index();
        int face = planeLocations[dim].get(i).fStartFace() ? (dim<<1) : (dim<<1)+1;
        
        SplitResult s = box.split( m_objects.get(objectIndex).getBoundingBox(), face );
        float probLeft = s.box1.surfaceArea() / box.surfaceArea();
        float probRight = s.box2.surfaceArea() / box.surfaceArea();
        
        int farthestAdvance = i;
        while ( farthestAdvance < planeLocations[dim].size() && ( planeLocations[dim].get(farthestAdvance).planeLocation() <= proposedPlane ) )
        {
          if ( planeLocations[dim].get(farthestAdvance).fStartFace() )
          {
            numLeft++;
            leftIndices[dim].add(planeLocations[dim].get(farthestAdvance).index());
            /*if ( dim == 2 )
            {
              print("Adding left : " + leftIndices[dim] + " for plane " + proposedPlane + "\n" );
            }*/
          }
          else
          {
            numRight--;
            rightIndices[dim].remove(planeLocations[dim].get(farthestAdvance).index());
            /*if ( dim == 2 )
            {
              print("Removing right : " + rightIndices[dim] + " for plane " + proposedPlane + "\n" );
            }*/
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
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        print("Adding plane " + minSplitPlane + " direction " + minSplitPlaneDirection + " " + minLeftIndices + " " + minRightIndices + "\n");
      }
      m_nodes.add( new KDTreeNode( minSplitPlane, minSplitPlaneDirection ) );
      int indexAdded = m_nodes.size() - 1;

      int left = recursiveCreate( minLeftIndices, minSplitResult.box1 );
      int right = recursiveCreate( minRightIndices, minSplitResult.box2 );
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

