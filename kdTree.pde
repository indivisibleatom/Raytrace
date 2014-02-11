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
    for (int i = 1; i < objects.size(); i++)
    {
      indices.add(i);
      m_boundingBox.grow( objects.get(i).getBoundingBox() );
    }
    m_boundingBox.debugPrint();
    //recursiveCreate( indices, m_boundingBox );
  }

  //Trivial sorting implementation right now
  private int recursiveCreate( ArrayList<Integer> indices, Box box )
  {
    float totalArea = box.surfaceArea();
    float minCost = Float.MAX_VALUE;
    float minSplitPlane = 0;
    int minSplitPlaneDirection = -1;

    ArrayList<Integer> leftIndices = new ArrayList<Integer>();
    ArrayList<Integer> rightIndices = new ArrayList<Integer>();
    ArrayList<Integer> minLeftIndices = new ArrayList<Integer>();
    ArrayList<Integer> minRightIndices = new ArrayList<Integer>();
    SplitResult minSplitResult = null;
    
    float costCurrent = intersectionCost * indices.size();
    for (int i = 0; i < indices.size(); i++)
    {
      for (int j = 0; j < 6; j++)
      {
        float proposedPlane = m_objects.get(indices.get(i)).getBoundingBox().getPlaneForFace(j);
        for (int k = 0; k < indices.size(); k++)
        {
          leftIndices = new ArrayList<Integer>();
          rightIndices = new ArrayList<Integer>();
          if ( m_objects.get(indices.get(k)).getBoundingBox().getPlaneForFace(j>>1) <= proposedPlane )
          {
            leftIndices.add(k);
          }
          else
          {
            rightIndices.add(k);
          }
          SplitResult s = box.split( m_objects.get(j).getBoundingBox(), j );
          float probLeft = s.box1.surfaceArea() / box.surfaceArea();
          float probRight = s.box2.surfaceArea() / box.surfaceArea();
          float cost = findCost( probLeft, probRight, leftIndices.size(), rightIndices.size() );
          if ( cost < minCost && cost < costCurrent )
          {
            minLeftIndices = leftIndices;
            minRightIndices = rightIndices;
            minCost = cost;
            minSplitPlaneDirection = j>>1;
            minSplitPlane = box.getPlaneForFace( j );
            minSplitResult = s;
          }
        }
      }
    }
    if ( minSplitPlaneDirection != -1 )
    {
      m_nodes.add( new KDTreeNode( minSplitPlane, minSplitPlaneDirection ) );
      int indexAdded = m_nodes.size() - 1;

      int left = recursiveCreate( minLeftIndices, minSplitResult.box1 );
      if ( minSplitPlaneDirection == -1 )
      {
        minSplitPlaneDirection = 3;
      }

      int right = recursiveCreate( minLeftIndices, minSplitResult.box2 );
      int otherChild = right<<2;
      m_nodes.get(indexAdded).setOtherChild( otherChild );
      return indexAdded;
    }
    else
    {
      m_nodes.add( new KDTreeNode( null, 3 ) );
      return m_nodes.size() - 1;
    }
  }
  
  public Box getBoundingBox()
  {
    return m_boundingBox;
  }
  
  /*private boolean intersectRecursive( Integer nodeIndex, Ray ray, float tMin, float tMax )
  {
    int axis = m_nodes.get(nodeIndex).getType();
    if ( axis == 3 )
    {
      for ( int i = 0; i < m_indices.size(); i++ )
      {
        if ( m_objects.get( m_indices.get(i) ).intersects( ray )
        {
          return true;
        }
      }
      return false;
    }

    int intersectionInfo = 
    int splitPos = m_nodes.get(nodeIndex).getSplitPlane();
    float tSplit = (split - ray.getPosition().get(axis))/ray.getDirection(axis);
    if ( axis == 0 ) //x axis
    {
    }
    return false;
  }*/
  
  public boolean intersects( Ray ray )
  {
    if ( !m_boundingBox.intersects( ray ) )
    {
      return false;
    }
    for ( int i = 0; i < m_objects.size(); i++ )
    {
      if ( m_objects.get(i).intersects( ray ) )
      {
        return true;
      }
    }
    return false;
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    if ( !m_boundingBox.intersects( ray ) )
    {
      return null;
    }

    IntersectionInfo minIntersectionInfo = null;
    float minT = Float.MAX_VALUE;   

    for ( int i = 0; i < m_objects.size(); i++ )
    {
      IntersectionInfo info = m_objects.get(i).getIntersectionInfo( ray );
      if ( info != null )
      {
        if ( info.t() < minT )
        {
          minIntersectionInfo = info;
          minT = info.t();
        }
      }
    }
    return minIntersectionInfo;
  }
}
