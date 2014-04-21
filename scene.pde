import java.util.*;

//Profiling information
class Scene
{
  private Camera m_camera;
  private SceneManager m_sceneManager;
  private LightManager m_lightManager;
  private Renderer m_renderer;
  private boolean m_fAnisotropic;
  private boolean m_fMipMapEnabled;
  private boolean m_fNPR;
  
  private Transformation m_currentTransformation;
  private Stack<Transformation> m_matrixStack;

  Scene()
  {
    m_sceneManager = new SceneManager();
    m_lightManager = new LightManager();
    m_camera = new Camera( 0, -1, new Rect(0, 0, width, height) );
    m_renderer = new SamplerRenderer( this );
    
    m_currentTransformation = new Transformation();
    m_matrixStack = new Stack<Transformation>();
    m_matrixStack.push( m_currentTransformation );
    
    m_fAnisotropic = true;
    m_fMipMapEnabled = false;
    m_fNPR = false;
  }
  
  public Camera getCamera()
  {
    return m_camera;
  }
  
  public LightedPrimitive intersects( Ray ray )
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
  
  public void setRaysPerPixel( int rpp )
  {
    m_renderer.setRaysPerPixel( rpp );
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
    long startTime = System.currentTimeMillis();
    m_camera.getFilm().clear();
    m_sceneManager.buildScene();
    long createTime = System.currentTimeMillis();
    print( "Diagnostic self log : Time taken for tree creation " + (createTime - startTime)/1000.0 + "seconds\n");
    m_renderer.render( this );
    long endTime = System.currentTimeMillis();
    print( "Diagnostic self log : Time for rendering " + (endTime - createTime)/1000.0 + "seconds\n");
    print( "Count of logged info " + count + "\n");
    redraw();
  }
  
  public void reRender()
  {
    long startTime = System.currentTimeMillis();
    m_camera.getFilm().clear();
    long createTime = System.currentTimeMillis();
    print( "Diagnostic self log : Time taken for tree creation " + (createTime - startTime)/1000.0 + "seconds\n");
    m_renderer.render( this );
    long endTime = System.currentTimeMillis();
    print( "Diagnostic self log : Time for rendering " + (endTime - createTime)/1000.0 + "seconds\n");
    print( "Count of logged info " + count + "\n");
    redraw();
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
  
  public void setLensParams( float radius, float center )
  {
    m_camera.setLensParams( radius, center );
  }

  public void addPointLight( Point pt, Color col )
  {
    m_lightManager.addLight( new PointLight(pt, col) );
  }
  
  public void addDiskLight( Point pt, float center, Vector normal, Color col )
  {
    m_lightManager.addLight( new DiskLight( pt, center, normal, col ) );
  }
  
  public void setAnimated()
  {
    m_camera.enableShutterSpeed();
  }
   
  //Material handling commands
  public void setCoeffs( Color ambient, Color diffuse )
  {
    m_sceneManager.setMaterial( ambient, diffuse );
  }
  
  public void setMaterialTexture( String fileName )
  {
    m_sceneManager.setMaterialTexture( fileName );
  }
  
  public void setShinyCoeffs( Color ambient, Color diffuse, Color shiny, float power, float kReflect )
  {
    m_sceneManager.setMaterial( ambient, diffuse, shiny, power, kReflect );
  }
  
  public Material getCurrentMaterial()
  {
    return m_sceneManager.getCurrentMaterial();
  }
  
  public void perlinNoiseWithScale( float scale )
  {
    ProceduralTexture texture = new PerlinProceduralTexture( scale );
    m_sceneManager.setMaterialProceduralTexture( texture );
  }

  public void setWoodTexture()
  {
    ProceduralTexture texture = new WoodTexture();
    m_sceneManager.setMaterialProceduralTexture( texture );
  }

  public void setMarbleTexture()
  {
    ProceduralTexture texture = new MarbleTexture();
    m_sceneManager.setMaterialProceduralTexture( texture );
  }
  
  public void setStoneTexture()
  {
    ProceduralTexture texture = new StoneTexture();
    m_sceneManager.setMaterialProceduralTexture( texture );
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
  
  public void toggleAnisotropic()
  {
    m_fAnisotropic = !m_fAnisotropic;
    reRender();
  }
  
  public boolean fAnisotropic()
  {
    return m_fAnisotropic;
  }
  
  public void enableMipMap(boolean fEnable)
  {
    m_fMipMapEnabled = fEnable;
  }
  
  public boolean fMipMapEnabled()
  {
    return m_fMipMapEnabled;
  }
  
  public void setNPR()
  {
    m_fNPR = true;
  }
  
  public boolean fNPR()
  {
    return m_fNPR;
  } 
}


