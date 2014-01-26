class Sampler
{
  private Rect m_sampleRect;
  private Sample m_currentSample;
  
  Sampler( Rect sampleRect )
  {
    m_sampleRect = sampleRect;
  }
  
  public Sampler getSubsampler( int numTasks, int taskNum )
  {
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
}
