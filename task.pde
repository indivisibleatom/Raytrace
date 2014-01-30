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
    LightManager lightManager = m_scene.getLightManager();
    if ( m_scene.intersects( ray ) )
    {
      IntersectionInfo info = m_scene.getIntersectionInfo( ray );
      if ( info == null ) // Can be the case when the t value is negative
      {
        return lightManager.getAmbient();
      }
      Color pixelColor = cloneCol( info.primitive().getAmbientCoeffs() );
      //Color pixelColor = combineColor( info.primitive().getAmbientCoeffs(), lightManager.getAmbient() );
      for (int i = 0; i < lightManager.getNumLights(); i++)
      {
        Light light = lightManager.getLight(i);
        Ray r = light.getRay( info.point() );
        r.advanceEpsilon();
        if ( !m_scene.intersects( r ) )
        {
          float cosine = info.normal().dot( r.getDirection() );
          float mag = r.getDirection().getMagnitude();
          Color lightColor = combineColor( info.primitive().getDiffuseCoeffs(), light.getColor() );
          lightColor.scale( cosine );
          pixelColor.add( lightColor );
        }
      }
      return pixelColor;
    }
    else
    {
      return lightManager.getAmbient();
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
