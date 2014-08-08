
#ifndef __MATH_TYPES
#define __MATH_TYPES

#define PI 3.141592653589f
#define PI_2 2.0f*PI
#define PI_DIV_2 PI*0.5f

typedef struct{double x,y;} DPOINT;
typedef DPOINT  			*LPDPOINT;
typedef float * LPFLOAT;
typedef double * LPDOUBLE;


typedef float f32;
typedef int	s32;
typedef unsigned int u32;
typedef char s8;
typedef unsigned char u8;
typedef float mat3[3][3];
typedef float mat4[16];

#pragma pack(2)			
typedef struct
{
	float r;
	float g;
	float b;
	float a;
}  bvec4;
typedef struct
{
	unsigned short r;
	unsigned short g;
	unsigned short b;
}  bvec4x;
#pragma pack()			

typedef struct
{
	short x;
	short y;
}  svec2;
typedef struct
{
	short x;
	short y;
	short z;
}  svec3;

typedef struct
{
	int x;
	int y;
}  ivec2;
typedef struct
{
	int x;
	int y;
	int z;
}  ivec3;

typedef struct
{
	float x;
	float y;
}  vec2;
typedef struct
{
	double x;
	double y;
}  dvec2;
typedef struct
{
	float x;
	float y;
	float z;
}  vec3;

typedef struct
{
	double x;
	double y;
	double z;
}  dvec3;

typedef struct
{
	float x;
	float y;
	float z;
	float w;
}  vec4;

typedef struct
{
	float xmn;
	float ymn;
	float xmx;
	float ymx;
}  bounds;

typedef struct
{
	double xmn;
	double ymn;
	double xmx;
	double ymx;
}  dbounds;

vec4 MakeVec4(float singleValue);

struct PlaneVec2 {
	vec2 point;
	vec2 normal;
};

struct PlaneVec3 {
	vec3 point;
	vec3 normal;
};



#endif