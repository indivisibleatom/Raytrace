//TODO msati3: Perhaps a revamp for the sample class?
class SampleManager
{
  Rect m_sampleRect;
  boolean m_fHasMoreSamples;
  int m_samplesPerPixel;
  int m_currentNumRays;
  private int m_x;
  private int m_y;
  private int t;

  SampleManager(Rect sampleRect, int samplesPerPixel)
  {
    m_sampleRect = sampleRect;
    m_samplesPerPixel = samplesPerPixel;
    m_fHasMoreSamples = true;
    m_currentNumRays = 0;
    m_x = sampleRect.X();
    m_y = sampleRect.Y();
  }
  
  public Sample advance()
  {
    if (m_fHasMoreSamples)
    {
      if ( m_currentNumRays >= m_samplesPerPixel )
      {
        m_currentNumRays = 0;
        m_x++;
        if ( m_x >= m_sampleRect.X() + m_sampleRect.width() )
        {
          m_y++;
          if ( m_y >= m_sampleRect.Y() + m_sampleRect.height() ) //If going outside the sampling region
          {
            m_fHasMoreSamples = false;
          }
          else
          {        
            m_x = m_sampleRect.X();
          }
        }
      }
    }
    if ( m_fHasMoreSamples )
    {
      m_currentNumRays++;
      return new Sample(m_x, m_y, m_samplesPerPixel);
    }
    return null;
  }
}

class Sample
{
  private float m_xSample;
  private float m_ySample;
  int m_x;
  int m_y;
    
  public float getX() { return m_xSample; }
  public float getY() { return m_ySample; }
  
  public int getPixelX() { return m_x; }
  public int getPixelY() { return m_y; }
  
  Sample(int x, int y, int samplesPerPixel)
  {
    m_x = x;
    m_y = y;
    randomSample();
  }
  
  public void debugPrint()
  {
    print("Sample x: " + m_x + " y: " + m_y + "\n");
  }
  
  private void randomSample()
  {
    m_xSample = m_x + random(1) - 0.5;
    m_ySample = m_y + random(1) - 0.5;
  }
}
