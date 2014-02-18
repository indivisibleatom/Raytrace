import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

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
    ExecutorService pool = Executors.newFixedThreadPool(coreMultiplier*cores);
    for (int i = 0; i < numTasks; i++)
    {
      SamplerRenderingTask task = new SamplerRenderingTask( scene, m_sampler, numTasks, i );
      Thread t = new Thread(task);
      pool.submit(t);
    }
    pool.shutdown();
    try
    {
      pool.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
    } catch ( InterruptedException ex )
    {
      print("Exception occurred! SampleRenderer render!");
    }
    scene.getCamera().getFilm().draw();
  }
}
