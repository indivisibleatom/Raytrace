interface Task extends Runnable
{
}

int numI = 0;
class SamplerRenderingTask implements Task
{
  private Scene m_scene;
  private Sampler m_sampler;
  
  SamplerRenderingTask( Scene scene, Sampler sampler, int numTasks, int taskNum )
  {
    m_scene = scene;
    m_sampler = sampler.getSubsampler( numTasks, taskNum );
  }
   
  private Color computeRadiance( Ray ray )
  {
    LightManager lightManager = m_scene.getLightManager();
    IntersectionInfo info = m_scene.getIntersectionInfo( ray );
    if ( info == null ) // Can be the case when the t value is negative
    {
      return lightManager.getAmbient();
    }
    numI++;
    Color pixelColor = cloneCol( info.ambient() );
    for (int i = 0; i < lightManager.getNumLights(); i++)
    {
      Light light = lightManager.getLight(i);
      Ray shadowRay = light.getRay( info.point() );
      
      if ( !m_scene.intersects( shadowRay ) )
      {
        float cosine = info.normal().dot( shadowRay.getDirection() );
        if ( cosine < 0 ) //Dual sided lighting
        {
          if ( info.fDualSided() )
          {
            cosine = -cosine;
          }
          else
          {
            cosine = 0;
          }
        }
        float mag = shadowRay.getDirection().getMagnitude();
        Color lightColor = combineColor( info.diffuse(), light.getColor() );
        lightColor.scale( cosine );
        pixelColor.add( lightColor );
      }
    }
    return pixelColor;
  }
  
  public void run()
  {
    Sample sample = m_sampler.getNextSample();
    int count = 0;
    do
    {
      Ray ray = m_scene.getCamera().getRay(sample);
      m_scene.getCamera().getFilm().setRadiance(sample, computeRadiance(ray));
      sample = m_sampler.getNextSample();
      count++;
    } while ( sample != null );
    print("Num times run " + count + "\n");
  }
}
