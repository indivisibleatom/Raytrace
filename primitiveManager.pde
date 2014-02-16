//TODO msati3: Switch to acceleration structure at a later time?
class PrimitiveManager
{
  private ArrayList<LightedPrimitive> m_primitives;
  private KDTree m_kdTree;
  
  PrimitiveManager()
  {
    m_primitives = new ArrayList<LightedPrimitive>();
  }
  
  public void addPrimitive( LightedPrimitive primitive )
  {
    m_primitives.add(primitive);
  }
  
  public void buildScene()
  {
    KDTreeCreator creator = new KDTreeCreator( m_primitives );
    m_kdTree = creator.create();
  }
  
  public boolean intersects( Ray ray )
  {
    return m_kdTree.intersects( ray, Float.MIN_VALUE, Float.MAX_VALUE );
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    return m_kdTree.getIntersectionInfo( ray, Float.MIN_VALUE, Float.MAX_VALUE );
  }
}
