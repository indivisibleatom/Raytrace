//TODO msati3: Create sampler hierarchy
class Sampler
{
  private Rect m_sampleRect;
  private SampleManager m_sampleManager;
  private int m_samplesPerPixel;
  
  Sampler( Rect sampleRect )
  {
    m_sampleRect = sampleRect;
    m_samplesPerPixel = 1;
    m_sampleManager = null;
  }
  
  public void setSamplesPerPixel( int spp )
  {
    m_samplesPerPixel = spp;
  }
  
  public int getSamplesPerPixel()
  {
    return m_samplesPerPixel;
  }
  
  public Sampler getSubsampler( int numTasks, int taskNum )
  {
    int tasksPerRow = (int)sqrt(numTasks);
    int tasksPerCol = (int)sqrt(numTasks);
    int widthPerSubSample = m_sampleRect.width() / tasksPerCol;
    int heightPerSubSample = m_sampleRect.height() / tasksPerRow;
    int rowForTask = taskNum / tasksPerRow;
    int colForTask = taskNum - (rowForTask * tasksPerRow);
    Rect subSampleRect = new Rect( colForTask * widthPerSubSample, rowForTask * heightPerSubSample, widthPerSubSample, heightPerSubSample );
    Sampler subSampler = new Sampler( subSampleRect );
    subSampler.m_samplesPerPixel = m_samplesPerPixel;
    return subSampler;
  }
  
  public Sample getNextSample()
  {
    //TODO msati3: See how to best adapt the Sampler interface to get samples correctly. Right now, just one sample per pixel
    if ( m_sampleManager == null )
    {
      m_sampleManager = new SampleManager( m_sampleRect, m_samplesPerPixel );
    }
    return m_sampleManager.advance();
  }
  
  public void debugPrint()
  {
    print("Begin Sampler: \n");
    m_sampleRect.debugPrint();
    print("End Sampler \n");
  }
}
