interface Renderer
{
  public void render( Scene scene );
}

class SamplerRenderer implements Renderer
{
  private Sampler m_sampler;
  
  SamplerRenderer( Scene scene )
  {
    Rect samplerRect = new Rect( 0, 0, width, height );
    m_sampler = new Sampler( samplerRect );
  }
  
  public void render( Scene scene )
  {
    int cores = Runtime.getRuntime().availableProcessors();
    int numTasks = 30;
    for (int i = 0; i < numTasks; i++)
    {
      if ( i == 0 )
      {
        SamplerRenderingTask task = new SamplerRenderingTask( scene, m_sampler, numTasks, i );
        Thread t = new Thread(task);
        t.start();
      }
    }
  }
}
