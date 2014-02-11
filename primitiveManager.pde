//TODO msati3: Switch to acceleration structure at a later time?
class PrimitiveManager
{
  private ArrayList<LightedPrimitive> m_primitives;
  private KDTree m_kdTree;
  
  PrimitiveManager()
  {
    m_primitives = new ArrayList<LightedPrimitive>();
    m_kdTree = new KDTree();
  }
  
  public void addPrimitive( LightedPrimitive primitive )
  {
    m_primitives.add(primitive);
  }
  
  public void buildScene()
  {
    m_kdTree.create( m_primitives );
  }
  
  public boolean intersects( Ray ray )
  {
    return m_kdTree.intersects( ray );
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    return m_kdTree.getIntersectionInfo( ray );
  }
}
