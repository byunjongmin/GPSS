# 수치지형발달모형 GPSS
- 프로그램명 : GPSS(Geomorphological Process System Simulator)
- 목적 : 지질시간 규모의 지형발달을 모의하는 프로그램
- 프로그램 언어 : MATLAB과 C (속도 향상을 위해 MEX 파일)
- 사사 : Gregory E. Tucker의 GOLEM과 Steven L. Eddins의 Upslope Toolbox 등과 같이 인터넷에 공개된 프로그램의 소스 코드 없이는 본 프로그램이 나올 수 없었음. 참고한 알고리듬은 개별 함수 코드에서 명시하였음.

# GPSS 설치
- GitHub GPSS 사이트(https://github.com/byunjongmin/GPSS)에서 소스코드 다운로드
- 압축 풀기 및 디렉토리 설정
  - GPSS 라는 디렉토리 생성 후(예. C:\GPSS), 압축 파일을 GPSS 디렉터리내에서 풀기
  - GPSS 디렉터리 내 data 디렉토리를 생성하고, data 디렉토리 안에 input(C:\GPSS\data\input)과 output 디렉토리 C:\GPSS\data\input)를 각각 만듦
- GPSS 소스코드 저장 디렉토리(C:\GPSS)를 MATLAB path에 추가함
- GPSS MATLAB MEX 파일 컴파일
  - 실행 속도를 높이기 위해 GPSS 일부 코드는 C 언어로 작성되었음. C언어로 작성한 부분은 C(또는 C++) 컴파일러로 컴파일을 해야함(https://www.mathworks.com/support/requirements/supported-compilers.html)
    - MEX 파일 : MATLAB에서 생성되는 함수로, C/C++ 프로그램 또는 Fortran 서브루틴을 호출함. MEX 함수는 MATLAB 스크립트 또는 함수처럼 동작함
    - GPSS MEX 파일 : CollapseMex.c, EstimateDElevByFluvialProcess.c, EstimateDElevByFluvialProcessBySDS.c, EstimateSubDTMex.c, EstimateUpstreamFlow.c, EstimateUpstramFlowBySDS.c, HillslopeProcessMex.c
    - Windows 운영체제에서는 컴파일러로 Visual Studio Community 설치를 권장함. 아래는 Visual Studio Community 설치 과정
      - 마이크로 소프트 비주얼 스튜디오 커뮤니티 사이트(https://visualstudio.microsoft.com/ko/vs/community/)에서 설치 파일(VisualStudioSetup.exe)을 다운로드하고 설치 파일을 실행하면 Visual Studio Installer 가 실행됨
      - 모듈 선택 창에서 “데스크톱 및 모바일” 아래 “C++을 사용한 데스크톱 개발” 모듈을 선택하고 설치 버튼 클릭
  - MATLAB 명령어 창에서 GPSS MEX 파일 컴파일 (예, > mex –v CollapseMex.c)
- GPSS 구동을 위한 toolbox 설치
  - Tree data structure as a MATLAB class (https://www.mathworks.com/matlabcentral/fileexchange/35623-tree-data-structure-as-a-matlab-class) 다운로드 및 MATLAB path 설정

# GPSS 프로그램 내 주요 함수 목록
- AccumulateUpstreamFlow : 상부 유역으로부터의 유량과 누적 셀 개수를 구하는 함수
- AdjustBoundary	: 경계조건에 따라 외곽 경계의 기반암 고도와 퇴적물 두께를 정의하는 함수
- CalcFacetFlow : 동-북동 facet 흐름의 향과 경사를 구하는 함수
- CalcInfinitiveFlow : Tarboton(1997)의 무한 유향 알고리듬을 이용하여 유향과 경사를 구하는 함수
- CalcSDSFlow : 최대 하부 경사를 가지는 이웃 셀을 찾아 이의 방향과 경사를 반환하고, 이 이웃 셀의 좌표를 SDSNbrX, SDSNbrY에기록하는 함수
- CheckOversteepSlopes : 활동 유형 - 천부활동(shallow landsliding)과 기반암활동(bedrock landsliding)에 따라 불안정한 사면을 파악하는 함수.
- Collapse : 불안정한 셀에서 활동을 발생시켜 사면 물질을 사면 하부로 연쇄적으로 이동시키는 함수.
- DefineUpliftRateDistribution : 융기율의 공간적 시간적 분포를 정의하는 함수
- EstimateSubDT	: 임시 세부 단위시간 동안 하천에 의한 고도 변화율을 이용해 하류 방향으로 다음 셀과의 경사가 0이 되는데 걸리는 시간[trialTime]을 구하여 이를 세부 단위시간으로 정의하는 함수
- FindSDSDryNbr : 가장 낮은 셀의 이웃 셀을 탐색하여 이웃 셀 중 flooded region에 속하지 않고 속하지 않고 동시에 최대 하부 경사를 가지는 이웃 셀이 있다면 가장 낮은 셀의 경사와 유향을 변경하고 조건을 만족하는 이웃 셀이 없다면 유출구가 없다고 반환하는 함수
- FluvialProcess	: 하천작용에 의한 퇴적층 두께 및 기반암 고도 변화율을 구하는 함수
- GPSSMain : GPSS 주함수
- HillslopeProcess : 사면작용에 의한 퇴적물 두께 변화율[m/dT]을 구하는 함수
- IsBoundary : 입력되는 셀의 좌표(y,x)가 모형 외곽 경계에 위치하는지를 확인하는 함수
- IsDry : 가장 낮은 셀의 이웃 셀의 flood 상태를 확인하여, 1) 유향이 정의되어 있거나 또는 SINK인 경우 true를 반환하고, 2) 현재 처리 중인 flooded region인 경우 false를 반환하는 함수
- LoadParameterValues : 파일에서 초기 변수값을 읽고 이를 출력하는 함수
- MakeFlatAreas	: 일정한 경사를 가진 평탄면을 만드는 함수
- MakeInitialGeomorphology	 : 초기 지형(초기 기반암 고도와 퇴적층 두께를 포함)을 만드는 함수
- ProcessSink : 유향이 정의되지 않은 셀(SINK)의 유출구를 찾아 이의 좌표를 SDSNbrY, SDSNbrX에 기록하는 함수
- RapidMassMovement : 불안정한 사면을 파악하고, 이들에 활동을 발생시키는 함수
- ReadElevation :	파일로부터 초기 지형의 고도를 읽어 들여 이를 반환하는 함수
- ReadParameterValue : 다양한 형태의 변수값을 읽는 함수
- RockWeathering : 단위시간 당 풍화율을 추정하는 함수.
- Uplift : 모형 영역에 지반융기를 반영하고, 융기로 인한 고도 변화율을 구하는 함수

# GPSS 입력 변수 설정 및 실행
- GPSS 모의실험을 위한 GPSS 입력변수 파일 생성
  - GPSS 모의실험을 위한 지형형성과정별 입력 변수를 설정
    - guideForParameterInput.xlsx 파일 내 지형형성과정별 입력 변수 설정을 돕는 각각의 시트를 참고할 것
      - 시트: Uplift, Weathering, Hillslope Process, Hydrology, Alluvial Channel, Bedrock Channel 
  - 설정한 입력변수를 기록한 GPSS 입력변수 파일을 생성
    - 참고 : OUTPUT_SUBDIR 변수의 값을 모의 날짜와 시간을 결합하여 만들 것을 권함(예. 20221118_1800)
    - guideForParameterInput.xlsx 파일 내 ‘For Output’ 시트에서 Write a Input Parameter 아이콘을 클릭하면 OUTPUT_SUBDIR 이름을 포함하는 입력 변수 파일을 생성함(예. parameter_20221118_1800.txt)
  - 생성한 GPSS 입력변수 파일을 input 디렉터리 내로 이동함
- GPSS 디렉터리(예. C:\GPSS)를 MATLAB ‘current folder’로 설정함
- MATLAB 명령창에 입력변수 파일 이름(예. parameter_20221118_1800.txt)을 인자로 넣고 GPSS 메인함수 실행
  - 예, GPSSMain_Hy('parameter_20221118_1800.txt’)

# GPSS 결과 확인 및 분석

## GPSS 모의결과 파일 확인
- 프로그램 구동이 끝나면 output 디렉터리내로 이동
- output 디렉토리내 OUTPUT_SUBDIR 변수값의 날짜와 시간으로 된 디렉터리로 이동(예. C:\GPSS\output\20221118_1800)
- GPSS 모의결과 파일을 확인함
  - sedThick.txt	: 퇴적층 두께 [m] 
  - bedrockElev.txt : 기반암 고도 [m] 
  - weatherProduct.txt : 풍화율 [m/dT] 
  - dSedThickByHillslope.txt : 사면작용에 의한 퇴적층 두께 변화율 [m3/m2 dT] 
  - chanBedSedBudget.txt : 하도 내 퇴적층 수지 [m3/dT] 
  - dSedThickByFluvial.txt : 하천작용에 의한 퇴적층 두께 변화율 [m3/m2 dT] 
  - dBedrockElevByFluvial.txt : 하천작용에 의한 기반암 고도 변화율 [m3/m2 dT] 
  - dSedThickByRapidMassmove.txt : 활동에 의한 퇴적층 두께 변화율 [m3/m2 dT] 
  - dBedrockElevByRapidMassmove.txt : 활동에 의한 기반암 고도 변화율 [m3/m2 dT] 
  - log.txt : GPSS 구동 동안의 상황 기록

## GPSS 모의결과 분석
- GPSS 디렉터리(예. C:\GPSS)를 MATLAB ‘current folder’로 설정함
- AnalyzeResultGeneral.m 함수 이용하여 과정을 분석
  - 예. GPSS 입력변수 파일이 parameter_20221118_1800.txt 일 경우,
  - > majorOutput = AnalyseResultGeneral(‘20221118_1800＇,＇parameter_20221118_1800.txt＇,1,1,1,1,1);
- ToGRIDobj 함수 이용하여 GPSS 모의결과를 TopoToolbox 객체로 변환하여 분석