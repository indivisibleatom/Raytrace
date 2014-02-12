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
    IntersectionInfo info = m_scene.getIntersectionInfo( ray );
    if ( info == null ) // Can be the case when the t value is negative
    {
      return lightManager.getAmbient();
    }
    Color pixelColor = cloneCol( info.primitive().getAmbientCoeffs() );
    for (int i = 0; i < lightManager.getNumLights(); i++)
    {
      Light light = lightManager.getLight(i);
      Ray shadowRay = light.getRay( info.point() );
      
      print("Here");
      return new Color(1,1,1);
      /*if ( !m_scene.intersects( shadowRay ) )
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
        Color lightColor = combineColor( info.primitive().getDiffuseCoeffs(), light.getColor() );
        lightColor.scale( cosine );
        pixelColor.add( lightColor );
      }*/
    }
    return pixelColor;
  }
  
  public void run()
  {
    Sample sample = m_sampler.getNextSample();
    for (int i = 0; i < 30; i++)
    {
      sample = m_sampler.getNextSample();
    }
    //do
    //{
      Ray ray = m_scene.getCamera().getRay(sample);
      m_scene.getCamera().getFilm().setRadiance(sample, computeRadiance(ray));
      sample = m_sampler.getNextSample();
    //} while ( sample != null );
  }
}
