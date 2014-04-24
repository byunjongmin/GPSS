/*
 * CollapseMex.c
 *
 * 높은 고도 순으로 활동에 의해 불안정한 셀에서 다음 셀로의 연속적인
 * 기반암 고도 및 퇴적층 두께 변화율을 구하는 함수 
 * * 참고: Collapse 함수의 while 반복문만을 MEX 파일로 변경함
 * 
 * dSedimentThickByIthCell ...      0 . i번째 불안정 셀로 인한 퇴적물 두께 변화율 [m/dT]
 * = CollapseMex ...
 * (mRows ...                       0 . 행 개수
 * ,nCols ...                       1 . 열 개수
 * ,isStable ...                    2 . 다음 셀로의 물질이동이 않는 안정화 여부
 * ,isBoundary ...                  3 . 연쇄적 이동의 외곽 경계 도달 여부
 * ,nextY ...                       4 . 다음 셀의 Y 좌표
 * ,nextX ...                       5 . 다음 셀의 X 좌표
 * ,rapidMassMovementType ...       6 . 활동 유형
 * ,dElev1)                         7 . i번째 셀의 침식율 [m/dT]
 *
 *----------------------------- mexGetVariablePtr 함수로 참조하는 변수
 *
 * dSedimentThickByIthCell          8 . i번째 불안정 셀로 인한 퇴적물 두께 변화율 [m/dT]
 * SDSNbrY ...                      9 . 다음 셀 Y 좌표
 * SDSNbrX ...                      10. 다음 셀 X 좌표
 * elev ...                         11. 갱신된 지표 고도 [m]
 * soilCriticalHeight ...           12. 천부활동의 안정 고도차 [m]
 * sedimentThick ...                13. 퇴적층 두께
 * oversteepSlopes ...              14. 안정 사면각 초과 셀
 * flood ...                        15. flooded region
 
 *
 */
# include "mex.h"

/* 계산 함수 선언 */
void CollapseMex(
    mwSize mRows,
    mwSize nCols,
    bool isStable,
    bool isBoundary,
    mwIndex nextY,
    mwIndex nextX,
    mwIndex rapidMassMovementType,
    double dElev1,
    double * SDSNbrY,
    double * SDSNbrX,
    double * elev,
    double * soilCriticalHeight,
    double * sedimentThick,
    double * oversteepSlopes,
    double * flood,
    double * dSedimentThickByithCell);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* 입력 변수 선언
     * 주의: mxArray 자료형 변수는 mexGetVariablePtr 함수를 이용하여
     * 호출함수의 작업공간에 있는 변수들의 포인터만 불러옴 */
    /* 호출함수 작업공간의 변수 */
    const mxArray * mxArray9;   /* for SDSNbrY */
    const mxArray * mxArray10;  /* for SDSNbrX */
    const mxArray * mxArray11;  /* for elev */
    const mxArray * mxArray12;  /* for soilCriticalHeight */
    const mxArray * mxArray13;  /* for sedimentThick */
    const mxArray * mxArray14;  /* for oversteepSlopes */
    const mxArray * mxArray15;  /* for flood */

    /* 출력 변수 선언 */
    mxArray * mxArray8;         /* for dSedimentThickByIthCell */
    
    /* 입력변수 실제 자료  */
    mwSize mRows;
    mwSize nCols;
    bool isStable;
    bool isBoundary;
    mwIndex nextY;
    mwIndex nextX;
    mwIndex rapidMassMovementType;
    double dElev1;
    
    double * SDSNbrY;
    double * SDSNbrX;
    double * elev;
    double * soilCriticalHeight;
    double * sedimentThick;
    double * oversteepSlopes;
    double * flood;
        
    /* 출력 변수 선언 */
    double * dSedimentThickByIthCell;
    
    /* 입력변수 초기화 */
    mRows = (mwSize) mxGetScalar(prhs[0]);
    nCols = (mwSize) mxGetScalar(prhs[1]);
    isStable = (bool) mxGetScalar(prhs[2]);
    isBoundary = (bool) mxGetScalar(prhs[3]);
    nextY = (mwIndex) mxGetScalar(prhs[4]);
    nextX = (mwIndex) mxGetScalar(prhs[5]);
    rapidMassMovementType = (mwIndex) mxGetScalar(prhs[6]);
    dElev1 = mxGetScalar(prhs[7]);
            
    mxArray9    = mexGetVariablePtr("caller","SDSNbrY");
    mxArray10   = mexGetVariablePtr("caller","SDSNbrX");
    mxArray11   = mexGetVariablePtr("caller","elev");
    mxArray12   = mexGetVariablePtr("caller","soilCriticalHeight");
    mxArray13   = mexGetVariablePtr("caller","sedimentThick");
    mxArray14   = mexGetVariablePtr("caller","oversteepSlopes");
    mxArray15   = mexGetVariablePtr("caller","flood");
    
    SDSNbrY                 = mxGetPr(mxArray9);
    SDSNbrX                 = mxGetPr(mxArray10);
    elev                    = mxGetPr(mxArray11);
    soilCriticalHeight      = mxGetPr(mxArray12);
    sedimentThick           = mxGetPr(mxArray13);
    oversteepSlopes         = mxGetPr(mxArray14);
    flood                   = mxGetPr(mxArray15);
    
    /* 출력 변수 초기화 */
    /* 호출 함수의 작업 공간에 있는 변수를 복사해서 불러옴 */
    mxArray8 = mexGetVariable("caller","dSedimentThickByIthCell"); 
    plhs[0] = mxArray8;
    
    /* 출력 변수의 자료에 포인터를 지정 */
    dSedimentThickByIthCell = mxGetPr(plhs[0]);    
    
    /* 서브 루틴 수행 */
    CollapseMex(
        mRows,
        nCols,
        isStable,
        isBoundary,
        nextY,
        nextX,
        rapidMassMovementType,
        dElev1,
        SDSNbrY,
        SDSNbrX,
        elev,
        soilCriticalHeight,
        sedimentThick,
        oversteepSlopes,
        flood,
        dSedimentThickByIthCell);
}

void CollapseMex(
    mwSize mRows,
    mwSize nCols,
    bool isStable,
    bool isBoundary,
    mwIndex nextY,
    mwIndex nextX,
    mwIndex rapidMassMovementType,
    double dElev1,
    double * SDSNbrY,
    double * SDSNbrX,
    double * elev,
    double * soilCriticalHeight,
    double * sedimentThick,
    double * oversteepSlopes,
    double * flood,
    double * dSedimentThickByIthCell)
{
   /* 상수 선언 */ 
   const mwIndex FLOODED = 2;
   const mwIndex SOIL = 1;
   
   mwIndex Y_TOP_BND,Y_BOTTOM_BND,X_LEFT_BND,X_RIGHT_BND;
   
   /* 임시 변수 선언 */
   mwIndex currentIdx,nextIdx,y,x;
   double dElev2;
   
   Y_TOP_BND = 1;
   Y_BOTTOM_BND = mRows;
   X_LEFT_BND = 1;
   X_RIGHT_BND = nCols; 
   
   /* 현 셀이 안정 사면이 되기전 또는 외곽 경계에 도달하기 전까지 다음 셀로
    * 사면작용이 반복됨 */
   while ((isStable == false) && (isBoundary == false))
   {
       /* 1. 다음 셀을 현 셀로 지시함 */
       y = nextY;
       x = nextX;
       
       /* 현 셀의 색인 */
       /* * 주의: MATLAB 배열 선형 색인을 위해 '-1'을 수행함 */
       currentIdx = (mwIndex) (x-1) * mRows + y - 1;
               
       nextY = (mwIndex) SDSNbrY[currentIdx];
       nextX = (mwIndex) SDSNbrX[currentIdx];
       
       /* 다음 셀의 색인 */
       /* * 주의: MATLAB 배열 선형 색인을 위해 '-1'을 수행함 */
       nextIdx = (mwIndex) (nextX-1) * mRows + nextY - 1;

        /* 2. 활동으로 인한 현 셀에서의 침식율 추정
         * 주의: 여기서는 (이동율을 추정하기 위한) 기준 고도가 지표고도로
         * 통일됨. 직전에서 기반암활동이 발생하였더라도 사면하부에서의 연쇄적
         * 물질 이동은 기반암활동과는 과정이 다르며 따라서 기반암활동에서와
         * 동일한 기준 고도 및 임계 고도차를 사용하지 않음. */
        dElev2 = -(((elev[currentIdx] - dElev1) - elev[nextIdx])
            - soilCriticalHeight[currentIdx]);

        /* 3. 조건에 따라 침식율을 조정함
         * 원리: 다음 셀의 고도는 현 셀에서의 사면물질 이동으로 인해 상승함.
         * 따라서 현재의 유효 고도차 상한보다 더 작은 양이 이동되어야 함.
         * * 주의: 다음 셀이 외곽 경계라면 줄이지 않으며, 연쇄 이동을 종료함.
         * * 주의: 다음 셀이 불안정한 셀일 경우에는 다음 셀에서의 물질 이동이
         *   많을 것으로 예상되므로 줄이지 않음 */                                          

        /* 추정한 침식율을 줄임 */
        dElev2 = dElev2 * 0.5;

        if ((nextY == Y_TOP_BND) || (nextY == Y_BOTTOM_BND)
            || (nextX == X_LEFT_BND) || (nextX == X_RIGHT_BND))
        {
            dElev2 = dElev2 * 2;
            
            if (dElev2 < 0)
            {
                /* 주의: 천부활동일 경우, 이동율은 퇴적층 두께에 제한됨 */
                if ((rapidMassMovementType == SOIL)
                    && (- dElev2 > sedimentThick[currentIdx]))
                {
                    dElev2 = dElev1 - sedimentThick[currentIdx];
                }

                dSedimentThickByIthCell[nextIdx] = dSedimentThickByIthCell[nextIdx] - dElev2;
            }
            isBoundary = true;        
        } /* if (nextY == */
        else if (oversteepSlopes[nextIdx] == true)
        {
            dElev2 = dElev2 * 2;
        } /* if (nextY == */
        
        /* 주의: (사면 하부의 연쇄 이동에서) 이동율은 퇴적층 두께에 제한됨 */
        if (- dElev2 > sedimentThick[currentIdx])
        {
            dElev2 = dElev1 - sedimentThick[currentIdx];
        }

        /* 4. 다음 셀의 고도 변화율 */
        if ((dElev2 >= 0) || (flood[currentIdx] == FLOODED))
        {
            /* 다음 셀로의 이동이 일어나지 않는 안정 사면이거나, flooded
             * region이라면 퇴적층 두께 변화율을 구하고 연쇄 이동을 종료함 */
            dSedimentThickByIthCell[currentIdx] = dSedimentThickByIthCell[currentIdx] - dElev1;
            
            isStable = true;
        }
        else if (- dElev1 >= - dElev2)
        {
            /* 여전히 다음 셀로의 물질 이동이 발생한다면 다음 셀로의 이동율을
             * 고려한 퇴적층 두께 변화율을 구함		 */
            dSedimentThickByIthCell[currentIdx]
                = dSedimentThickByIthCell[currentIdx] - dElev1 + dElev2;
            
            dElev1 = dElev2;

        /* else  - dElev1 < - dElev2
         
            * 현 셀이 애초 불안정한 셀이었다면, 다음 ithCell에서 처리하도록 건너뜀 */            
        } /* if (dElev2 >= 0) */
   } /* while (~isStable */
} /* void Collapse */