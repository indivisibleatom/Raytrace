class SceneManager
{
  private SceneGraph m_sceneGraph;
  private PrimitiveManager m_primitiveManager;
  private Material m_currentMaterial;
  private HashMap<String, ImageTexture> m_textures;
  
  SceneManager()
  {
    //TODO msati3: See if we need to implement a scenegraph
    m_primitiveManager = new PrimitiveManager();
    m_currentMaterial = new Material( new Color(0,0,0), new Color(0,0,0) );
    m_textures = new HashMap<String, ImageTexture>();
  }
  
  public void addPrimitive(LightedPrimitive p)
  {
    m_primitiveManager.addPrimitive(p);
  }
  
  public void addNamedPrimitive(String name)
  {
    m_primitiveManager.addNamedPrimitive(name);
  }
  
  public void startList()
  {
    m_primitiveManager.startList();
  }
  
  public void commitList()
  {
    m_primitiveManager.commitList();
  }
  
  public void commitAccel()
  {
    m_primitiveManager.commitAccel();
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
  
  public void setMaterialTexture( String fileName )
  {
    ImageTexture imageTexture = m_textures.get( fileName );
    if ( imageTexture == null )
    { 
      imageTexture = new ImageTexture( fileName );
    }
    m_currentMaterial.setTexture( imageTexture );
  }
  
  public void setMaterial( Color ambient, Color diffuse, Color shiny, float power, float kReflect )
  {
    m_currentMaterial = new Material( ambient, diffuse, shiny, power, kReflect );
  }
  
  public void buildScene()
  {
    m_primitiveManager.buildScene();
  }
  
  public Material getCurrentMaterial()
  {
    return m_currentMaterial;
  }
  
  public LightedPrimitive intersects( Ray ray )
  {
    return m_primitiveManager.intersects( ray );
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    return m_primitiveManager.getIntersectionInfo( ray );
  } 
}
