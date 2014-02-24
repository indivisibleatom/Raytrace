import java.util.*;

//Profiling information
class Scene
{
  private Camera m_camera;
  private SceneManager m_sceneManager;
  private LightManager m_lightManager;
  private Renderer m_renderer;
  Transformation m_currentTransformation;
  Stack<Transformation> m_matrixStack;

  Scene()
  {
    m_sceneManager = new SceneManager();
    m_lightManager = new LightManager();
    m_camera = new Camera( 0, -1, new Rect(0, 0, width, height) );
    m_renderer = new SamplerRenderer( this );
    
    m_currentTransformation = new Transformation();
    m_matrixStack = new Stack<Transformation>();
    m_matrixStack.push( m_currentTransformation );
  }
  
  public Camera getCamera()
  {
    return m_camera;
  }
  
  public boolean intersects( Ray ray )
  {
    return m_sceneManager.intersects( ray );
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    return m_sceneManager.getIntersectionInfo( ray );
  }
  
  public void setCameraFov( float fov )
  {
    m_camera.setFov( fov );
  }
  
  public void addNamedObject( String name )
  {
    m_sceneManager.addNamedPrimitive( name );
  }
  
  public void instantiateObject( String name )
  {
    m_sceneManager.addPrimitive( name, m_currentTransformation );
  }
  
  public void addObject(LightedPrimitive obj)
  {
    m_sceneManager.addPrimitive(obj);
  }
  
  public void startList()
  {
    m_sceneManager.startList();
  }
  
  public void commitList()
  {
    m_sceneManager.commitList();
  }
  
  public void commitAccel()
  {
    m_sceneManager.commitAccel();
  }
  
  public void raytrace()
  {
    m_sceneManager.buildScene();
    m_renderer.render( this );
  }
  
  //Light commands
  public LightManager getLightManager()
  {
    return m_lightManager;
  }
  
  public void setBackgroundColor( Color bgColor )
  {
    m_lightManager.setAmbient( bgColor );  
  }

  public void addPointLight( Point pt, Color col )
  {
    m_lightManager.addLight( new PointLight(pt, col) );
  }
   
  //Material handling commands
  public void setCoeffs( Color ambient, Color diffuse )
  {
    m_sceneManager.setMaterial( ambient, diffuse );
  }
  
  public Material getCurrentMaterial()
  {
    return m_sceneManager.getCurrentMaterial();
  }
  
  //Matrix stack commands
  public Transformation getCurrentTransformation()
  {
    return m_currentTransformation;
  }
  
  public void translate( Vector translate )
  {
    m_currentTransformation.translate( translate );
  }
  
  public void scale( Vector scale )
  {
    m_currentTransformation.scale( scale );
  }
  
  public void rotate( float angle, Vector axis )
  {
    m_currentTransformation.rotate( angle, axis );
  }
   
  public void onPush()
  {
    Transformation newTrans = new Transformation();
    newTrans.clone( m_currentTransformation );
    m_matrixStack.push( m_currentTransformation );
    m_currentTransformation = newTrans;
  }
  
  public void onPop()
  {
    m_currentTransformation = m_matrixStack.pop();
  }
}


