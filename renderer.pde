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
    int numTasks = 25;
    ArrayList<Thread> workerThreads = new ArrayList<Thread>();
    for (int i = 0; i < numTasks; i++)
    {
      SamplerRenderingTask task = new SamplerRenderingTask( scene, m_sampler, numTasks, i );
      Thread t = new Thread(task);
      workerThreads.add(t);
      t.start();
    }
    for (int i = 0; i < workerThreads.size(); i++)
    {
        try
        {
          workerThreads.get(i).join();
        } catch ( InterruptedException ex )
        {
        }
    }
    scene.getCamera().getFilm().draw();
  }
}
