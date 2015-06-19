import processing.serial.*;
import processing.pdf.*;
Serial port; 
boolean record ;
String nowStat ;
int lf = 10 ;
int iLight_Counts = 16 ;
int[][] Aver_Stat = new int[10][iLight_Counts] ;
int[] iLight_Vals = new int[iLight_Counts], iPre_Light_Vals = new int[iLight_Counts] ;
int cAmount = 5; // amount of cloud
int w,h;
float[] fMagic = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 } ;
float[][] fCircle_Size = new float[5][iLight_Counts] ; // , fPre_Circle_Size = new float[iLight_Counts] ;
float[][] fCloud_Alpha = new float[5][iLight_Counts] ; // , fPre_Cloud_Alpha = new float[iLight_Counts] ;

int[][] rPoint = new int[5][iLight_Counts];
int[][] gPoint = new int[5][iLight_Counts];
int[][] bPoint = new int[5][iLight_Counts];

int[] iAlpha_Limit = { 200, 0 } ;

float border = 5 ;
float[] fWidth = new float[cAmount];
float[] fHeight = new float[cAmount]; // Wdth Height of Clould center
float[] fWidthMove = new float[cAmount];
float[] fHeightMove = new float[cAmount]; // Width Height of Clould center
int[] fWidthDir = new int[cAmount];
int[] fHeightDir = new int[cAmount]; // Width Height of Clould center

//boolean sketchFullScreen() {
//  return true;
//}

int[] iInit_Values = new int[iLight_Counts] ;

float[][] R = new float[cAmount][iLight_Counts], G = new float[cAmount][iLight_Counts], B = new float[cAmount][iLight_Counts] ;

void setup(){ /// Processing Setup

        beginRecord( PDF, "frame-####.pdf" );
        sketchFullScreen() ;
        background(120, 210, 250) ;
        port = new Serial( this, Serial.list()[7], 9600 ) ;
        size( displayWidth, displayHeight ) ;
        noStroke() ; // initail Eniroment
      
        initailPosition(0, width, height);  
        
        for ( int i = 0 ; i < iLight_Counts ; i ++ ) {
            iLight_Vals[i] = 0 ;
            iPre_Light_Vals[i] = 200 ;
        } // for()
  
        // Delay 3 seconds and read 10 pair numbers.
        delay( 1000 ) ;
        nowStat = port.readStringUntil( lf ) ;
        delay( 1000 ) ;
        nowStat = port.readStringUntil( lf ) ;
        
        for ( int i = 0 ; i < 10 ; i ++ ) {
            delay( 100 ) ;
            nowStat = port.readStringUntil( lf ) ;
            Aver_Stat[i] = int( splitTokens( nowStat, "," ) ) ;
            //println( nowStat ) ;
        } // for
  
        // Get average to 'iInit_Values'.
        for ( int i = 0 ; i < 10 ; i ++ )
          for ( int j = 0 ; j < iLight_Counts ; j ++ )
            iInit_Values[j] += Aver_Stat[i][j] / 10 ;
        
} // setup()


void draw() {
  /*
  if (record) {
    // Note that #### will be replaced with the frame number. Fancy!
    beginRecord(PDF, "frame-####.pdf"); 
      noStroke();
  }
  */

  if ( 0 < port.available() ) {
    nowStat = port.readStringUntil( lf ) ;
    if ( nowStat != null ) {
      print( "\n Receiving:" + nowStat ) ;        
      iLight_Vals = int( splitTokens( nowStat, "," ) ) ;
  
      if ( iLight_Vals.length >= iLight_Counts ) {
        for ( int i = 0 ; i < iLight_Counts ; i ++ )
          if ( abs( iLight_Vals[i] - iPre_Light_Vals[i] ) <= 50 )
            iLight_Vals[i] = iPre_Light_Vals[i] ;
        
        for ( int i = 0 ; i < iLight_Counts ; i ++ )
          if ( iLight_Vals[i] >= iInit_Values[i] )
            iLight_Vals[i] = iInit_Values[i] ;
       
        for ( int i = 0 ; i < iLight_Counts ; i ++ )
          if ( iInit_Values[i] >= iLight_Vals[i] )
            fCircle_Size[0][i] = map( iLight_Vals[i], 0, iInit_Values[i], width * fMagic[i] / border, 0 ) ;
        
        for ( int i = 0 ; i < iLight_Counts ; i ++ )
          if ( iInit_Values[i] >= iLight_Vals[i] )
            fCloud_Alpha[0][i] = map( iLight_Vals[i], iAlpha_Limit[1], iInit_Values[i], iAlpha_Limit[0], iAlpha_Limit[1] ) ;
 
        // Clean window.
        background( 120, 210, 250 ) ; 
        creatCloud(0);

      } // if 
        
    } // if    
    /*  
    if (record) {
      endRecord();
      record = false;
    } // if
    */
  } // if
    
} // draw()
  // Use a keypress so thousands of files aren't created
  
void keyPressed() {
  noStroke();
  record = true;
} // keyPressed()


float fCircleOffset(int fCircleNumber, int fCircleDevide) {
  float cF;
  cF = fCircle_Size[0][fCircleNumber] / fCircleDevide;
  return cF;
}


        // creat Cloud
        /**
void creatCloudori() {
        fHeightMove = 1;
        fHeight += fHeightMove*fHeightDir;  
        fWidthMove = 1;
        fWidth += fWidthMove*fWidthDir;  
        // Base 16 clouds.
        for ( int i = 0 ; i < iLight_Counts ; i ++ ) {
          // Cloud Colors.
          rPoint[i] *= ( R[i] >= 255 || R[i] <= 150 ) ? -1 : 1 ;
          gPoint[i] *= ( G[i] >= 255 || G[i] <= 150 ) ? -1 : 1 ;
          bPoint[i] *= ( B[i] >= 255 || B[i] <= 150 ) ? -1 : 1 ;
          R[i] += random( 0, 3 ) * rPoint[i] ;
          G[i] += random( 0, 3 ) * gPoint[i] ;
          B[i] += random( 0, 3 ) * bPoint[i] ;
          
          fill( B[i], fCloud_Alpha[i] ) ;
          // Cloud draw size.
          int x_temp = i % 4, y_temp = i / 4 ;
          float x_real = 0, y_real= 0 ;
          
          x_real = ( fWidth ) + ( ( ( x_temp == 0 || x_temp == 1 ) ? -1 : 1 ) * fCircleOffset(i,2) ) + ( ( x_temp == 0 ) ? - fCircleOffset(i+1, 2) : 0 ) + ( ( x_temp == 3 ) ? fCircleOffset(i-1,2) : 0 ) ;
          y_real = ( fHeight ) + ( ( ( y_temp == 0 || y_temp == 1 ) ? -1 : 1 ) * fCircleOffset(i,3) ) + ( ( y_temp == 0 ) ? -fCircleOffset(i+4, 3) : 0 ) + ( ( y_temp == 3 ) ? fCircleOffset(i-4,3) : 0 ) ;
          
       
        
          ellipse( x_real, y_real, fCircle_Size[i], fCircle_Size[i] ) ;
        } // for
        
        
        // Bonus clouds.
        fill( 255, ( fCloud_Alpha[1] + fCloud_Alpha[2] ) * 2 / 3 ) ;
        ellipse( ( fWidth ), ( fHeight ) - ( fCircleOffset(1,3) + fCircleOffset(2,3) + ( fCircleOffset(5,3) ) + fCircleOffset(6,3) ) / 2, ( fCircleOffset(1,3) + fCircleOffset(2,3) )* 2, ( fCircleOffset(1,3) + fCircleOffset(2,3) )* 2 ) ; 
        fill( 255, ( fCloud_Alpha[5] + fCloud_Alpha[6] ) * 2 / 3 ) ;
        ellipse( ( fWidth ), ( fHeight ) - ( fCircleOffset(5,3) + fCircleOffset(6,3) ) / 2, ( fCircleOffset(5,3) + fCircleOffset(6,3) ) * 2, ( fCircleOffset(5,3)+ fCircleOffset(6,3) ) * 2) ;
        fill( 255, ( fCloud_Alpha[9] + fCloud_Alpha[10] ) * 2 / 3 ) ;
        ellipse( ( fWidth ), ( fHeight ) + ( fCircleOffset(9,3) + fCircleOffset(10,3) ) / 2, ( fCircleOffset(9,3) + fCircleOffset(10,3) ) * 2, ( fCircleOffset(9,3) + fCircleOffset(10,3) ) * 2) ;
        fill( 255, ( fCloud_Alpha[13] + fCloud_Alpha[14] ) * 2 / 3 ) ;
        ellipse( ( fWidth ), ( fHeight ) + ( fCircleOffset(13,3) + fCircleOffset(14,3) + fCircleOffset(9,3) + fCircleOffset(10,3)) / 2, ( fCircleOffset(13,3) + fCircleOffset(14,3) ) * 2, ( fCircle_Size[13] + fCircle_Size[14] ) * 2 / 3 ) ; 
        
        fill( 255, ( fCloud_Alpha[4] + fCloud_Alpha[8] ) * 2 / 3 ) ;
        ellipse( ( fWidth ) - ( ( fCircle_Size[4] / 3 ) + ( fCircle_Size[8] / 3 ) ) / 2, ( fHeight ), ( fCircle_Size[4] + fCircle_Size[8] ) * 2 / 3, ( fCircle_Size[4] + fCircle_Size[8] ) * 2 / 3 ) ;
        fill( 255, ( fCloud_Alpha[7] + fCloud_Alpha[11] ) * 2 / 3 ) ;
        ellipse( ( fWidth ) + ( ( fCircle_Size[7] / 3 ) + ( fCircle_Size[11] / 3 ) ) / 2, ( fHeight ), ( fCircle_Size[7] + fCircle_Size[11] ) * 2 / 3, ( fCircle_Size[7] + fCircle_Size[11] ) * 2 / 3 ) ;     
        
    } // function Cloud
    
    **/


       
void creatCloud(int cNum) {
      
        fHeightMove[cNum] = 1;
        fHeight[cNum] += fHeightMove[cNum] * fHeightDir[cNum];  
        fWidthMove[cNum] = 1;
        fWidth[cNum] += fWidthMove[cNum] * fWidthDir[cNum];  
        
        // Base 16 clouds.
        for ( int i = 0 ; i < iLight_Counts ; i ++ ) {
          // Cloud Colors.
          rPoint[cNum][i] *= ( R[cNum][i] >= 255 || R[cNum][i] <= 150 ) ? -1 : 1 ;
          gPoint[cNum][i] *= ( G[cNum][i] >= 255 || G[cNum][i] <= 150 ) ? -1 : 1 ;
          bPoint[cNum][i] *= ( B[cNum][i] >= 255 || B[cNum][i] <= 150 ) ? -1 : 1 ;
          R[cNum][i] += random( 0, 3 ) * rPoint[cNum][i] ;
          G[cNum][i] += random( 0, 3 ) * gPoint[cNum][i] ;
          B[cNum][i] += random( 0, 3 ) * bPoint[cNum][i] ;
          
          //fill( 255, fCloud_Alpha[cNum][i] ) ;
          
          fill( B[cNum][i], fCloud_Alpha[cNum][i] ) ;
          // Cloud draw size.
          
          int x_temp = i % 4, y_temp = i / 4 ;
          float x_real = 0, y_real= 0 ;
          
          x_real = ( fWidth[cNum] ) + ( ( ( x_temp == 0 || x_temp == 1 ) ? -1 : 1 ) * fCircleOffset(i,2) ) + ( ( x_temp == 0 ) ? - fCircleOffset(i+1, 2) : 0 ) + ( ( x_temp == 3 ) ? fCircleOffset(i-1,2) : 0 ) ;
          y_real = ( fHeight[cNum] ) + ( ( ( y_temp == 0 || y_temp == 1 ) ? -1 : 1 ) * fCircleOffset(i,3) ) + ( ( y_temp == 0 ) ? -fCircleOffset(i+4, 3) : 0 ) + ( ( y_temp == 3 ) ? fCircleOffset(i-4,3) : 0 ) ;
        
          ellipse( x_real, y_real, fCircle_Size[cNum][i], fCircle_Size[cNum][i] ) ;
          //println( "X:"+ x_real +",Y:"+ y_real +",Size:"+ fCircle_Size[cNum][i] +",Color:"+ B[cNum][i] +",Alpha:"+fCloud_Alpha[cNum][i]) ;
        } // for

        
        // Bonus clouds.
        fill( 255, ( fCloud_Alpha[cNum][1] + fCloud_Alpha[cNum][2] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ), ( fHeight[cNum] ) - ( fCircleOffset(1,3) + fCircleOffset(2,3) + ( fCircleOffset(5,3) ) + fCircleOffset(6,3) ) / 2, ( fCircleOffset(1,3) + fCircleOffset(2,3) )* 2, ( fCircleOffset(1,3) + fCircleOffset(2,3) )* 2 ) ; 
        fill( 255, ( fCloud_Alpha[cNum][5] + fCloud_Alpha[cNum][6] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ), ( fHeight[cNum] ) - ( fCircleOffset(5,3) + fCircleOffset(6,3) ) / 2, ( fCircleOffset(5,3) + fCircleOffset(6,3) ) * 2, ( fCircleOffset(5,3)+ fCircleOffset(6,3) ) * 2) ;
        fill( 255, ( fCloud_Alpha[cNum][9] + fCloud_Alpha[cNum][10] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ), ( fHeight[cNum] ) + ( fCircleOffset(9,3) + fCircleOffset(10,3) ) / 2, ( fCircleOffset(9,3) + fCircleOffset(10,3) ) * 2, ( fCircleOffset(9,3) + fCircleOffset(10,3) ) * 2) ;
        fill( 255, ( fCloud_Alpha[cNum][13] + fCloud_Alpha[cNum][14] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ), ( fHeight[cNum] ) + ( fCircleOffset(13,3) + fCircleOffset(14,3) + fCircleOffset(9,3) + fCircleOffset(10,3)) / 2, ( fCircleOffset(13,3) + fCircleOffset(14,3) ) * 2, ( fCircle_Size[cNum][13] + fCircle_Size[cNum][14] ) * 2 / 3 ) ; 
        
        fill( 255, ( fCloud_Alpha[cNum][4] + fCloud_Alpha[cNum][8] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ) - ( ( fCircle_Size[cNum][4] / 3 ) + ( fCircle_Size[cNum][8] / 3 ) ) / 2, ( fHeight[cNum] ), ( fCircle_Size[cNum][4] + fCircle_Size[cNum][8] ) * 2 / 3, ( fCircle_Size[cNum][4] + fCircle_Size[cNum][8] ) * 2 / 3 ) ;
        fill( 255, ( fCloud_Alpha[cNum][7] + fCloud_Alpha[cNum][11] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ) + ( ( fCircle_Size[cNum][7] / 3 ) + ( fCircle_Size[cNum][11] / 3 ) ) / 2, ( fHeight[cNum] ), ( fCircle_Size[cNum][7] + fCircle_Size[cNum][11] ) * 2 / 3, ( fCircle_Size[cNum][7] + fCircle_Size[cNum][11] ) * 2 / 3 ) ;     
        
    } // function Cloud

void initailPosition(int cNum, int w, int h) {
        fHeightDir[cNum] = -1;
        fWidthDir[cNum] = -1;
        fWidth[cNum] = w/2;
        fHeight[cNum] = h/2; /// Center of CLOUD
        print(fWidth[cNum],fHeight[cNum]);
        for ( int i = 0 ; i < iLight_Counts ; i ++ ) {
                R[cNum][i] = random( 190, 255 ) ;
                G[cNum][i] = random( 190, 255 ) ;
                B[cNum][i] = random( 190, 255 ) ;
                } // for
} //initailPosition

         /*
          if ( x_temp == 0 )
            x_real = ( width / 2 ) - fCircle_Size[i]/2 - fCircle_Size[i+1]/2 ;
          else if ( x_temp == 1 )
            x_real = ( width / 2 ) - fCircle_Size[i]/2 ;
          else if ( x_temp == 2 )
            x_real = ( width / 2 ) + fCircle_Size[i]/2 ;
          else if ( x_temp == 3 )
            x_real = ( width / 2 ) + fCircle_Size[i-1]/2 + fCircle_Size[i]/2 ;
          if ( y_temp == 0 )
            y_real = ( height / 2 ) - fCircle_Size[i]/3 - fCircle_Size[i+4]/3 ;
          else if ( y_temp == 1 )
            y_real = ( height / 2 ) - fCircle_Size[i]/3 ;
          else if ( y_temp == 2 )
            y_real = ( height / 2 ) + fCircle_Size[i]/3 ;
          else if ( y_temp == 3 )
            y_real = ( height / 2 ) + fCircle_Size[i]/3 + fCircle_Size[i-4]/3 ;
          */
