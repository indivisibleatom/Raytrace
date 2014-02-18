//TODO msati3: Switch to acceleration structure at a later time?
class PrimitiveManager
{
  private ArrayList<Primitive> m_primitives;
  private HashMap<String, Primitive> m_namedPrimitives;
  private ArrayList<Primitive> m_listPrimitives;
  private KDTree m_kdTree;
  boolean m_fInsertInList;
  
  PrimitiveManager()
  {
    m_primitives = new ArrayList<Primitive>();
    m_namedPrimitives = new HashMap<String, Primitive>();
    m_listPrimitives = new ArrayList<Primitive>();
    m_fInsertInList = false;
  }
  
  public void addPrimitive( Primitive primitive )
  {
    m_primitives.add(primitive);
  }
  
  public Primitive getPrimitive( String name )
  {
    return m_namedPrimitives.get( name );
  }
  
  public void onBeginList()
  {
    m_fInsertInList = true;
  }
  
  public void onEndList()
  {
    BoundingBox b = new BoundingBox( m_listPrimitives );
    addPrimitive( b );
    m_listPrimitives = new ArrayList<Primitive>();
    m_fInsertInList = false;
  }
    
  public void addNamedPrimitive(String name)
  {
    Primitive namedPrimitive = m_primitives.remove( m_primitives.size() - 1 );
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
