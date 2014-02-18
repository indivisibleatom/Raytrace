class Sample
{
  private int m_x;
  private int m_y;
  Rect m_sampleRect;
  boolean m_fHasMoreSamples;
  
  public int getX() { return m_x; }
  public int getY() { return m_y; }
  
  Sample(Rect sampleRect)
  {
    m_sampleRect = sampleRect;
    m_x = sampleRect.X();
    m_y = sampleRect.Y();
    m_fHasMoreSamples = true;
  }
  
  public boolean hasNextSample() 
  {
    return m_fHasMoreSamples;
  }
  
  public void debugPrint()
  {
    print("Sample x: " + m_x + " y: " + m_y + "\n");
  }
  
  public void advance()
  {
    if (m_fHasMoreSamples)
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
    }
  }
}
