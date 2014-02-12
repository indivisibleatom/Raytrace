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
    if ( DEBUG && DEBUG_MODE >= VERBOSE )
    {   
      m_boundingBox.debugPrint();
    }
    recursiveCreate( indices, m_boundingBox );
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

    ArrayList<Integer> leftIndices = new ArrayList<Integer>();
    ArrayList<Integer> rightIndices = new ArrayList<Integer>();
    ArrayList<Integer> minLeftIndices = new ArrayList<Integer>();
    ArrayList<Integer> minRightIndices = new ArrayList<Integer>();
    SplitResult minSplitResult = null;

    float costCurrent = intersectionCost * indices.size();
    float minCost = Float.MAX_VALUE;
    for (int i = 0; i < indices.size(); i++)
    {
      for (int j = 0; j < 6; j++)
      {
        float proposedPlane = m_objects.get(indices.get(i)).getBoundingBox().getPlaneForFace(j);
        leftIndices = new ArrayList<Integer>();
        rightIndices = new ArrayList<Integer>();
        for (int k = 0; k < indices.size(); k++)
        {
          if ( m_objects.get(indices.get(k)).getBoundingBox().getPlaneForFace(j | 1) <= proposedPlane )
          {
            leftIndices.add(indices.get(k));
          }
          else if ( m_objects.get(indices.get(k)).getBoundingBox().getPlaneForFace(j&0xFFFFFFFE) >= proposedPlane )
          {
            rightIndices.add(indices.get(k));
          }
          else
          {
            leftIndices.add(indices.get(k));
            rightIndices.add(indices.get(k));
          }
        }
        SplitResult s = box.split( m_objects.get(indices.get(i)).getBoundingBox(), j );
        float probLeft = s.box1.surfaceArea() / box.surfaceArea();
        float probRight = s.box2.surfaceArea() / box.surfaceArea();
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
          float cost = findCost( probLeft, probRight, leftIndices.size(), rightIndices.size() );
          if ( cost < minCost && cost < costCurrent )
          {
            minLeftIndices = leftIndices;
            minRightIndices = rightIndices;
            minCost = cost;
            minSplitPlaneDirection = j>>1;
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
      if ( info == null || localInfo.t() < info.t() )
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
      return getIntersectionInfoLeaf( nodeIndex, ray, tMin, tMax );
    }
  
    float splitPos = m_nodes.get(nodeIndex).getSplitPlane();
    if ( ray.getDirection().get(axis) == 0 )
    {
      ray.perturbDirection(axis);
    }
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

    if ( tSplit <= tMin )
    {
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        printTree( farChild );
        print("\n");
      }
      return getIntersectionInfoRecursive( farChild, ray, tMin, tMax );
    }
    else if ( tSplit >= tMax )
    {
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        printTree( nearChild );
        print("\n");
      }
      return getIntersectionInfoRecursive( nearChild, ray, tMin, tMax );
    }
    else
    {
      if ( DEBUG && DEBUG_MODE >= VERBOSE )
      {
        printTree( nodeIndex );
        print("\n");
      }
      IntersectionInfo info = getIntersectionInfoRecursive( nearChild, ray, tMin, tSplit );
      if ( info != null )
      {
        return info;
      }
      return getIntersectionInfoRecursive( farChild, ray, tSplit, tMax );
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
    float tSplit = (splitPos - ray.getOrigin().get(axis))/ray.getDirection().get(axis);
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

    if ( tSplit <= tMin )
    {
      return intersectsRecursive( farChild, ray, tMin, tMax );
    }
    else if ( tSplit >= tMax )
    {
      return intersectsRecursive( nearChild, ray, tMin, tMax );
    }
    else
    {
      boolean intersects = intersectsRecursive( nearChild, ray, tMin, tSplit );
      if ( intersects != false )
      {
        return intersects;
      }
      return intersectsRecursive( farChild, ray, tSplit, tMax );
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
    intersectionInfo = getIntersectionInfoRecursive( 0, ray, tExtents[0], tExtents[1] );
    /*if ( tExtents != null )
    {
      IntersectionInfo localInfo = null;
      for (int i = 0; i < m_objects.size(); i++)
      {
        localInfo = m_objects.get(i).getIntersectionInfo( ray, tMin, tMax );
        if ( localInfo != null )
        {
          if ( intersectionInfo == null || intersectionInfo.t() > localInfo.t() )
          {
            intersectionInfo = localInfo;
          }
        }
      }
      //intersectionInfo = getIntersectionInfoRecursive( 0, ray, tExtents[0], tExtents[1] );
    }*/
    return intersectionInfo;
  }
}

