class Material
{
  private Color m_ambient;
  private Color m_diffuse;
  private Color m_specular;
  private float m_power;
  private float m_reflect;
  private ImageTexture m_texture;

  Material( Color ambient, Color diffuse )
  {
    this( ambient, diffuse, null, 0, 0 );
  }
  
  Material( Color ambient, Color diffuse, Color shiny, float power, float reflect )
  {
    m_ambient = ambient;
    m_diffuse = diffuse;
    m_specular = shiny;
    m_power = power;
    m_reflect = reflect;
    m_texture = null; 
  }
  
  void setTexture( ImageTexture texture )
  {
    m_texture = texture; 
  }
  
  public Color diffuse() { return m_diffuse; }
  public Color ambient() { return m_ambient; } 
  public Color specular() { return m_specular; }
  public float power() { return m_power; }
  public float reflectConst() { return m_reflect; }
  public boolean fHasTexture() { return m_texture != null; }
  public Color getTextureColor( Point textureCoord )
  {
    PVector lookUpCoord = new PVector( textureCoord.X(), textureCoord.Y(), textureCoord.Z() );
    PVector colorLookUp = m_texture.color_value( lookUpCoord );
    return new Color( colorLookUp.x,colorLookUp.y, colorLookUp.z ); 
  }
}
