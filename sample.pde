//TODO msati3: Perhaps a revamp for the sample class?
class Sample
{
  private int m_x;
  private int m_y;
  private float m_xSample;
  private float m_ySample;
  Rect m_sampleRect;
  boolean m_fHasMoreSamples;
  int m_samplesPerPixel;
  int m_currentNumRays;
  
  public float getX() { return m_xSample; }
  public float getY() { return m_ySample; }
  
  public int getPixelX() { return m_x; }
  public int getPixelY() { return m_y; }
  public int getSamplesPerPixel() { return m_samplesPerPixel; }
  
  Sample(Rect sampleRect, int samplesPerPixel)
  {
    m_sampleRect = sampleRect;
    m_x = sampleRect.X();
    m_y = sampleRect.Y();
    m_samplesPerPixel = samplesPerPixel;
    m_fHasMoreSamples = true;
    m_currentNumRays = 0;
  }
  
  public boolean hasNextSample() 
  {
    return m_fHasMoreSamples;
  }
  
  public void debugPrint()
  {
    print("Sample x: " + m_x + " y: " + m_y + "\n");
  }
  
  private void subSample()
  {
    m_xSample = random(1) - 0.5;
    m_ySample = random(1) - 0.5;
  }
  
  public void advance()
  {
    if (m_fHasMoreSamples)
    {
      if ( m_currentNumRays < m_samplesPerPixel )
      {
        subSample();
      }
      else
      {
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
        subSample();
      }
    }
  }
}
