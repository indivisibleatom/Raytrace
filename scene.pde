class Scene
{
  private Camera m_camera;
  private SceneManager m_sceneManager;
  private ArrayList<Light> m_lights;
  private Renderer m_renderer;

  Scene()
  {
    m_sceneManager = new SceneManager();
    m_camera = new Camera( 0, -1, new Rect(0, 0, width, height) );
    m_renderer = new SamplerRenderer( this );
  }
  
  public Camera getCamera()
  {
    return m_camera;
  }
  
  public boolean intersects( Ray ray )
  {
    return m_sceneManager.intersects(ray);
  }
  
  public void setCameraFov( float fov )
  {
    m_camera.setFov( fov );
  }
  
  public void addObject(Primitive obj)
  {
    m_sceneManager.addPrimitive(obj);
  }
  
  public void setBackgroundColor( Color bgColor )
  {
  }
  
  public void addPointLight( Point pt, Color col )
  {
  }
  
  public void raytrace()
  {
    m_renderer.render( this );
  }  
}


