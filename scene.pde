class Scene
{
  private Camera m_camera;
  private SceneManager m_sceneManager;
  private ArrayList<Lights> m_lights;
  private Renderer m_renderer;
  private boolean m_fRayTraced;

  Scene()
  {
    m_fRayTraced = false;
  }
  
  void draw()
  {
    /*if (m_fRayTraced)
    {
      m_camera.getFilm().draw();
    }*/
  }
  
  public setCameraFov()
  {
    
  }
  
  public setBackgroundColor()
  {
  }
  
  public addPointLight()
  {
  }
  
  public void raytrace()
  {
    m_renderer.render( this );
    m_fRayTraced = true;
  }  
}


