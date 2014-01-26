class Camera
{
  private Film m_film;
  private float m_fov;
  
  Camera( float fov, int zNear, Rect screenDim )
  {
    m_fov = fov * (PI / 180);
    m_film = new Film( screenDim );
  }
  
  public void getFilm()
  {
    return m_film;
  }
  
  public Point toCamera( Point point )
  {
    Rect dimension = m_file.getDim();
    
  }
  
  public void getRay( Sample sample )
  {
    toCamera( sample.getX(), sample.getX(), -1 );
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
  
  public Rect getDim() { return m_screenDim; }
  
  public void setRadiance( Sample sample, Color col )
  {
    //TODO msati3: Remove hardcoding of single color being equated
    m_screenColor[sample.getPixelY()][sample.getPixelX()] = col;  

    put( i, j, getIntColor(m_screenColor[i][j]) );
  }
  
  /*void draw()
  {
    for ( int i = screenDim.Y(); i < screenDim.Y() + screenDim.height(); i++ )
    {
      for ( int j = screenDim.X(); j < screenDim.X() + screenDim.width(); j++ )
      {
        put( i, j, getIntColor(m_screenColor[i][j]) );
      }
    }
  }*/
}
