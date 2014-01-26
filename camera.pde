class Camera
{
  private Film m_film;
  private float m_fov;
  
  Camera( float fov, int zNear, Rect screenDim )
  {
    m_film = new Film( screenDim );
  }
  
  void getFilm()
  {
    return m_film;
  }
}

class Film
{
  private Rect m_screenDim;
  private Color[][] m_screenColor;
  
  Film( Rect screenDim )
  {
    m_screenDim = screenDim;
  }
  
  void setRadiance( Sample sample, Color col )
  {
    m_screenColor[sample.getPixelY()][sample.getPixelX()].add( col );
  }
  
  void draw()
  {
    for ( int i = screenDim.Y(); i < screenDim.Y() + screenDim.height(); i++ )
    {
      for ( int j = screenDim.X(); j < screenDim.X() + screenDim.width(); j++ )
      {
        put( i, j, getIntColor(m_screenColor[i][j]) );
      }
    }
  }
}
