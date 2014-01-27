//TODO msati3: Create sampler hierarchy
class Sampler
{
  private Rect m_sampleRect;
  private Sample m_currentSample;
  private int m_numberSamplesPerPixel;
  
  Sampler( Rect sampleRect )
  {
    m_sampleRect = sampleRect;
    m_numberSamplesPerPixel = 1; //TODO msati3: Change this to settable number at a later time
  }
  
  public Sampler getSubsampler( int numTasks, int taskNum )
  {
    //TODO msati3: Change the sumsampling code to be more robust later
    int tasksPerRow = (int)sqrt(numTasks);
    int tasksPerCol = (int)sqrt(numTasks);
    int widthPerSubSample = m_sampleRect.width() / tasksPerCol;
    int heightPerSubSample = m_sampleRect.height() / tasksPerRow;
    int rowForTask = taskNum / tasksPerRow;
    int colForTask = taskNum - rowForTask * tasksPerRow;
    Rect subSampleRect = new Rect( colForTask * widthPerSubSample, rowForTask * heightPerSubSample, widthPerSubSample, heightPerSubSample );
    return new Sampler( subSampleRect );
  }
  
  public Sample getNextSample()
  {
    //TODO msati3: See how to best adapt the Sampler interface to get samples correctly. Right now, just one sample per pixel
    if ( m_currentSample == null )
    {
      m_currentSample = new Sample( m_sampleRect );
    }
    else
    {
      m_currentSample.advance();
      if ( !m_currentSample.hasNextSample() )
      {
        return null;
      }
    }
    return m_currentSample;
  }
  
  public void debugPrint()
  {
    print("Begin Sampler: \n");
    m_sampleRect.debugPrint();
    print("End Sampler \n");
  }
}
