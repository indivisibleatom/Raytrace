class Material
{
  private float[] m_ambient;
  private float[] m_diffuse;

  Material( float[] amb, float[] diffuse )
  {
    m_ambient = amb;
    m_diffuse = diffuse;
  }
  
  public float[] getDiffuse() { return m_diffuse; }
  public float[] getAmbient() { return m_ambient; } 
}
