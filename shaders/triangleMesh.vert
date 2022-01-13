#version 460

layout (location = 0) in vec3 vPosition;
layout (location = 1) in vec3 vNormal;
layout (location = 2) in vec3 vColor;
layout (location = 3) in vec2 vTexUV;

layout (location = 4) in vec3 iPos;
layout (location = 5) in vec3 iRot;
layout (location = 6) in vec3 iScale;
layout (location = 7) in int  iTexIdx;

layout(set = 0, binding = 0) uniform  CameraBuffer {
	mat4 view;
	mat4 proj;
	mat4 viewproj;
} cameraData;

layout (push_constant) uniform constants
{
	vec4 data;
	mat4 render_matrix;
} PushConstants;


layout (location = 0) out vec3 outColor;
layout (location = 1) out vec2 outTexUV;
layout (location = 2) out flat int  outTexIdx;

mat4 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(axis.x * axis.x + c,           axis.x * axis.y - axis.z * s,  axis.z * axis.x + axis.y * s,  0.0,
                axis.x * axis.y + axis.z * s,  axis.y * axis.y + c,           axis.y * axis.z - axis.x * s,  0.0,
                axis.z * axis.x - axis.y * s,  axis.y * axis.z + axis.x * s,  axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

mat4 translationMatrix(vec3 pos)
{
    return mat4(
        1, 0, 0, pos.x,
        0, 1, 0, pos.y,
        0, 0, 1, pos.z,
        0, 0, 0, 1.0
    );
}

void main()
{
    mat3 _mx, _my, _mz;

	// rotate around x
	float s = sin(iRot.x);
	float c = cos(iRot.x);
    _mx = mat3(
        c,   s,   0.0,
       -s,   c,   0.0,
        0.0, 0.0, 1.0
    );

	// rotate around y
	s = sin(iRot.y);
	c = cos(iRot.y);
    _my = mat3(
        c,   0.0,   s,
        0.0, 1.0,   0.0,
       -s,   0.0,   c
    );

	// rot around z
	s = sin(iRot.z);
	c = cos(iRot.z);
    _mz = mat3(
        1.0, 0.0, 0.0,
        0.0,   c,   s,
        0.0,  -s,   c
    );

	mat3 rotMat = _mz * _my * _mx;

    // mat4 rotation_matrix = rotationMatrix(vec3(0, 0, 1),);

    vec4 v_pos = vec4(vPosition * rotMat, 1.0);
    vec4 pos = vec4((v_pos.xyz * iScale/2) + iPos, 1.0) ;
    // vec4 pos = vec4((pos.xyz) + );

	gl_Position = cameraData.proj * ( cameraData.view * pos);
	outColor = vColor;
    outTexIdx = iTexIdx;
    outTexUV = vTexUV;
}
