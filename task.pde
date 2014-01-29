interface Task extends Runnable
{
}

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
    if ( m_scene.intersects( ray ) )
    {
      IntersectionInfo info = m_scene.getIntersectionInfo( ray );
      LightManager lightManager = m_scene.getLightManager();
      Color pixelColor = Color.combine( info.primitive().getAmbientCoeffs(), lightManager.getAmbient() );
      for (int i = 0; i < lightManager.getNumLights(); i++)
      {
        Light light = lightManager.getLight(i);
        Ray r = light.getRay( info.point() );
        if ( !m_scene.intersects( r ) )
        {
          float cosine = info.normal().dot( r.getDirection() );
          Color lightColor = Color.combine( info.primitive().getDiffuseCoeffs(), light.getColor() );
          lightColor.scale( cosine );
          pixelColor.append( lightColor );
        }
      }
    }
    else
    {
      return m_scene.getBackgroundColor();
    }
  }
  
  public void run()
  {
    Sample sample = m_sampler.getNextSample();
    do
    {
      Ray ray = m_scene.getCamera().getRay(sample);
      m_scene.getCamera().getFilm().setRadiance(sample, computeRadiance(ray));
      sample = m_sampler.getNextSample();
    } while ( sample != null );
  }
}
