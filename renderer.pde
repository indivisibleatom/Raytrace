interface Renderer
{
  public void render( Scene scene );
}

class SamplerRenderer implements Renderer
{
  private Sampler m_sampler;
  
  SamplerRenderer( Sampler sampler, Scene scene )
  {
    m_sampler = sampler;
  }
  
  private int numSamplerTasks( Scene scene )
  {
  }
  
  public void render( Scene scene )
  {
    int numPixels = scene.getCamera().getFilm().getWidth();
    int cores = Runtime.getRuntime().availableProcessors();
    int numTasks = 32 * cores;
    for (int i = 0; i < numTasks; i++)
    {
      SamplerRenderingTask task = new SamplerRenderingTask( scene, numTasks, i );
    }
  }
}
