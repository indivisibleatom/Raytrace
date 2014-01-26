interface Task implements Runnable
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
  
  //TODO msati3: Change this to correct algorithm
  private Color computeRadiance( Ray ray )
  {
    if ( m_scene.intersects( ray ) )
    {
      return new Color(1.0,1.0,1.0);
    }
    return Color(0.0, 0.0, 0.0);
  }
  
  public void run()
  {
    Sample sample = m_sampler.getNextSample();
    Ray ray = m_scene.getCamera().getRay(sample);
    m_scene.getCamera().getFilm().setRadiance(sample, computeRadiance(ray));
  }
}
