//TODO msati3: Switch to acceleration structure at a later time?
class PrimitiveManager
{
  private ArrayList<LightedPrimitive> m_primitives;
  private HashMap<String, LightedPrimitive> m_namedPrimitives;
  private KDTree m_kdTree;
  
  PrimitiveManager()
  {
    m_primitives = new ArrayList<LightedPrimitive>();
    m_namedPrimitives = new HashMap<String, LightedPrimitive>();
  }
  
  public void addPrimitive( LightedPrimitive primitive )
  {
    m_primitives.add(primitive);
  }
  
  public LightedPrimitive getPrimitive( String name )
  {
    return m_namedPrimitives.get( name );
  }
    
  public void addNamedPrimitive(String name)
  {
    LightedPrimitive namedPrimitive = m_primitives.remove( m_primitives.size() - 1 );
    m_namedPrimitives.put( name, namedPrimitive );
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
