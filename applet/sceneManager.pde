class SceneManager
{
  private SceneGraph m_sceneGraph;
  private PrimitiveManager m_primitiveManager;
  private Material m_currentMaterial;
  
  SceneManager()
  {
    //TODO msati3: See if we need to implement a scenegraph
    m_primitiveManager = new PrimitiveManager();
    m_currentMaterial = new Material( new Color(0,0,0), new Color(0,0,0) );
  }
  
  public void addPrimitive(LightedPrimitive p)
  {
    m_primitiveManager.addPrimitive(p);
  }
  
  public void addNamedPrimitive(String name)
  {
    m_primitiveManager.addNamedPrimitive(name);
  }
  
  public void addPrimitive(String name, Transformation transformation )
  {
    LightedPrimitive namedPrimitive = m_primitiveManager.getPrimitive( name );
    InstancePrimitive instancePrimitive = new InstancePrimitive( namedPrimitive, transformation );
    addPrimitive( instancePrimitive );
  }
  
  public void setMaterial( Color ambient, Color diffuse )
  {
    m_currentMaterial = new Material( ambient, diffuse );
  }
  
  public void buildScene()
  {
    m_primitiveManager.buildScene();
  }
  
  public Material getCurrentMaterial()
  {
    return m_currentMaterial;
  }
  
  public boolean intersects( Ray ray )
  {
    return m_primitiveManager.intersects( ray );
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    return m_primitiveManager.getIntersectionInfo( ray );
  } 
}
