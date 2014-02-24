//TODO msati3: Switch to acceleration structure at a later time?
class PrimitiveManager
{
  private ArrayList<LightedPrimitive> m_primitives;
  private HashMap<String, LightedPrimitive> m_namedPrimitives;
  private ArrayList<LightedPrimitive> m_currentList;
  private KDTree m_kdTree;
  private boolean m_fAddToList;
  
  PrimitiveManager()
  {
    m_primitives = new ArrayList<LightedPrimitive>();
    m_namedPrimitives = new HashMap<String, LightedPrimitive>();
    m_currentList = new ArrayList<LightedPrimitive>();
    m_fAddToList = false;
  }
  
  public void addPrimitive( LightedPrimitive primitive )
  {
    if ( !m_fAddToList )
    {
      m_primitives.add(primitive);
    }
    else
    {
      m_currentList.add(primitive);
    }
  }
  
  public void startList()
  {
    m_fAddToList = true;
    m_currentList.clear();
  }
  
  public void commitList()
  {
    BoundingBox box = new BoundingBox(m_currentList);
    m_fAddToList = false;
    addPrimitive(box);
  }
  
  public void commitAccel()
  {
    KDTreeCreator creator = new KDTreeCreator(m_currentList);
    m_fAddToList = false;
    KDTree kdTree = creator.create();
    addPrimitive(kdTree);
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
