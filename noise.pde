// Classic Perlin noise, 3D version

Vector dNoise(float x, float y, float z)
{
  float delta = 0.1;
  float noiseVal = noise_3d( x, y, z );
  float noiseValDx = noise_3d( x+delta, y, z ) -  noiseVal;
  float noiseValDy = noise_3d( x, y+delta, z ) - noiseVal;
  float noiseValDz = noise_3d( x, y, z+delta ) - noiseVal;
  Vector v = new Vector( noiseValDx, noiseValDy, noiseValDz );
  return v;
}

float noise_3d(float x, float y, float z) {
  
  // make sure we've initilized table
  if (init_flag == false) {
    initialize_table();
    init_flag = true;
  }
  
  // Find unit grid cell containing point
  int X = fastfloor(x);
  int Y = fastfloor(y);
  int Z = fastfloor(z);
  
  // Get relative xyz coordinates of point within that cell
  x = x - X;
  y = y - Y;
  z = z - Z;
  
  // Wrap the integer cells at 255 (smaller integer period can be introduced here)
  X = X & 255;
  Y = Y & 255;
  Z = Z & 255;
  
  // Calculate a set of eight hashed gradient indices
  int gi000 = perm[X+perm[Y+perm[Z]]] % 12;
  int gi001 = perm[X+perm[Y+perm[Z+1]]] % 12;
  int gi010 = perm[X+perm[Y+1+perm[Z]]] % 12;
  int gi011 = perm[X+perm[Y+1+perm[Z+1]]] % 12;
  int gi100 = perm[X+1+perm[Y+perm[Z]]] % 12;
  int gi101 = perm[X+1+perm[Y+perm[Z+1]]] % 12;
  int gi110 = perm[X+1+perm[Y+1+perm[Z]]] % 12;
  int gi111 = perm[X+1+perm[Y+1+perm[Z+1]]] % 12;
  
  // The gradients of each corner are now:
  // g000 = grad3[gi000];
  // g001 = grad3[gi001];
  // g010 = grad3[gi010];
  // g011 = grad3[gi011];
  // g100 = grad3[gi100];
  // g101 = grad3[gi101];
  // g110 = grad3[gi110];
  // g111 = grad3[gi111];
  
  // Calculate noise contributions from each of the eight corners
  double n000= dot(grad3[gi000], x, y, z);
  double n100= dot(grad3[gi100], x-1, y, z);
  double n010= dot(grad3[gi010], x, y-1, z);
  double n110= dot(grad3[gi110], x-1, y-1, z);
  double n001= dot(grad3[gi001], x, y, z-1);
  double n101= dot(grad3[gi101], x-1, y, z-1);
  double n011= dot(grad3[gi011], x, y-1, z-1);
  double n111= dot(grad3[gi111], x-1, y-1, z-1);
  
  // Compute the fade curve value for each of x, y, z
  double u = fade(x);
  double v = fade(y);
  double w = fade(z);
  
  // Interpolate along x the contributions from each of the corners
  double nx00 = mix(n000, n100, u);
  double nx01 = mix(n001, n101, u);
  double nx10 = mix(n010, n110, u);
  double nx11 = mix(n011, n111, u);
  
  // Interpolate the four results along y
  double nxy0 = mix(nx00, nx10, v);
  double nxy1 = mix(nx01, nx11, v);
  
  // Interpolate the two last results along z
  float nxyz = (float) mix(nxy0, nxy1, w);
  
  return nxyz;
}

boolean init_flag = false;

int grad3[][] = {{1,1,0},{-1,1,0},{1,-1,0},{-1,-1,0},
{1,0,1},{-1,0,1},{1,0,-1},{-1,0,-1},
{0,1,1},{0,-1,1},{0,1,-1},{0,-1,-1}};

int p[] = {151,160,137,91,90,15,
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180};

// To remove the need for index wrapping, double the permutation table length
int perm[] = new int[512];

void initialize_table() {
  for(int i=0; i<512; i++) perm[i]=p[i & 255];
}

// This method is a *lot* faster than using (int)Math.floor(x)
int fastfloor(double x) {
  return x>0 ? (int)x : (int)x-1;
}

double dot(int g[], double x, double y, double z) {
  return g[0]*x + g[1]*y + g[2]*z;
}

double mix(double a, double b, double t) {
  return (1-t)*a + t*b;
}

double fade(double t) {
  return t*t*t*(t*(t*6-15)+10);
}

class WorleyResult
{
  private int m_identity;
  private float m_distance1;
  private float m_distance2;
  
  WorleyResult( int identity, float distance1, float distance2 )
  {
    set( identity, distance1, distance2 );
  }
  
 public void set( int identity, float distance1, float distance2 )
 {
    m_identity = identity;
    m_distance1 = distance1;
    m_distance2 = distance2;
 } 
  
  public int ID() { return m_identity; }
  public float distance1() { return m_distance1; }
  public float distance2() { return m_distance2; } 
}

class WorleyNoise
{
  float[] m_poissonLookUp;
  int m_modulo;
  
  WorleyNoise(float pointDensity)
  {
    populatePoissonLookUp( pointDensity );
    m_modulo = (int)pow(2, 20);
  }
  
  private void populatePoissonLookUp( float pointDensity )
  {
    m_poissonLookUp = new float[10];
    float expPointDensity = 1/pow((float)Math.E, pointDensity);
    float fact = 1;
    m_poissonLookUp[0] = expPointDensity; 
    for (int i = 1; i <= 9; i++)
    {
      fact = fact * i;
      m_poissonLookUp[i] = m_poissonLookUp[i-1] + pow(pointDensity, i) * expPointDensity / fact;
    }
  }
  
  private int hash( int x, int y, int z )
  {
    return ((541 * x + 79 * y + 31 * z)%m_modulo);
  }
  
  private int getNumFeaturePoints( float random )
  {
    for (int i = 1; i < 10; i++)
    {
      if ( random < m_poissonLookUp[i] )
      {
        return i;
      }
    }
    return 9;
  }
  
  private void evaluateAt( Point p, int cubeX, int cubeY, int cubeZ, int scale, WorleyResult currentResult )
  {
   int seed = hash( cubeX, cubeY, cubeZ );

    randomSeed( seed );
    float rand = random(0,1);
    int numPoints = getNumFeaturePoints( rand );
    Point featurePoint;

    int id = currentResult.ID();
    float minDist = currentResult.distance1();
    float minDist2 = currentResult.distance2();

    for ( int i = 0; i < numPoints; i++ )
    {
      float x = random(0,1);
      float y = random(0,1);
      float z = random(0,1);
      featurePoint = new Point(0,0,0);
      featurePoint.set( (cubeX + x)/scale, (cubeY + y)/scale, (cubeZ + z)/scale );
      Vector dVec = new Vector( featurePoint, p );
      float dist = dVec.getMagnitude();
      if ( dist < 0.001 )
      {
        minDist2 = minDist;
        minDist = 0;
        id = 1000021; 
      }
      else if ( dist < minDist )
      {
        minDist2 = minDist;
        minDist = dist;
        id = seed + i;
      }
      else if ( dist < minDist2 )
      {
        minDist2 = dist;
      }
    }

    currentResult.set( id, minDist, minDist2 );
  }

  public WorleyResult valueAt( Point p, int scale )
  {
    int cubeXInit = (int)Math.floor(scale*p.X()); int cubeYInit = (int)Math.floor(scale*p.Y()); int cubeZInit = (int)Math.floor(scale*p.Z());
    WorleyResult res = new WorleyResult( -1, Float.MAX_VALUE, Float.MAX_VALUE ); 
    evaluateAt( p, cubeXInit, cubeYInit, cubeZInit, scale, res );
    
    for (int i = -1; i < 1; i++)
    {
      for (int j = -1; j < 1; j++)
      {
        for (int k = -1; k < 1; k++)
        {
          if ( ! (i == 0 && j == 0 && k == 0) )
          {
            evaluateAt( p, cubeXInit - i, cubeYInit - j, cubeZInit - k, scale, res );
          }
        }
      }
    }
    return res;
  }
}
