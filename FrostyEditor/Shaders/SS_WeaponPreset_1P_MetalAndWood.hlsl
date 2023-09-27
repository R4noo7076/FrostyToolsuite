
#if defined(TWO_TEXCOORDS_NO_COLOR) || defined(TWO_TEXCOORDS_ONE_COLOR) || defined(TWO_TEXCOORDS_TWO_COLOR)
	#define MAX_TEXCOORDS 2
#endif

#if defined(THREE_TEXCOORDS_NO_COLOR) || defined(THREE_TEXCOORDS_ONE_COLOR)
	#define MAX_TEXCOORDS 3
#endif

#if defined(FOUR_TEXCOORDS_NO_COLOR) || defined(FOUR_TEXCOORDS_ONE_COLOR)
	#define MAX_TEXCOORDS 4
#endif

// -----------------------------------------------------------------------------------
// Vertex Shader
// -----------------------------------------------------------------------------------

struct VertexShaderIntermediates
{
	float4 Pos : SV_POSITION;
	float4 WorldPos : TEXCOORD0;
	float4 Tangent : TEXCOORD1;
	float4 Binormal : TEXCOORD2;
	float4 Normal : TEXCOORD3;
	float4 TexCoords : TEXCOORD4;
};

VertexShaderIntermediates GetVertexShaderIntermediates(VertexShaderInput Input)
{
	VertexShaderIntermediates Intermediates = (VertexShaderIntermediates)0;
	
    Intermediates.Pos = TransformPosition(Input, Input.Pos.xyz);
	Intermediates.WorldPos = mul(worldMatrix, float4(Input.Pos.xyz, 1.0f));
	
	float3 normal = TransformTBN(Input, Input.Normal.xyz);
	float3 tangent = TransformTBN(Input, Input.Tangent.xyz);
	float3 binormal = TransformTBN(Input, cross(Input.Normal.xyz, Input.Tangent.xyz) * Input.BinormalSign);
	
	Intermediates.Tangent.xyz = float3(tangent.x, binormal.x, normal.x);
	Intermediates.Binormal.xyz = float3(tangent.y, binormal.y, normal.y);
	Intermediates.Normal.xyz = float3(tangent.z, binormal.z, normal.z);
	
	Intermediates.TexCoords = float4(Input.TexCoord0, Input.TexCoord1);
#if MAX_TEXCOORDS > 2
	Intermediates.Tangent.w = Input.TexCoord2.x;
	Intermediates.Binormal.w = Input.TexCoord2.y;
#endif
	
	return Intermediates;
}

// -----------------------------------------------------------------------------------
// Pixel Shader
// -----------------------------------------------------------------------------------

float cmp(bool condition)
{
	return (condition) ? 1 : 0;
}
float2 cmp(bool2 condition)
{
	return float2(
			(condition.x) ? 1 : 0,
			(condition.y) ? 1 : 0
			);
}
float3 cmp(bool3 condition)
{
	return float3(
			(condition.x) ? 1 : 0,
			(condition.y) ? 1 : 0,
			(condition.z) ? 1 : 0
			);
}
float4 cmp(bool4 condition)
{
	return float4(
			(condition.x) ? 1 : 0,
			(condition.y) ? 1 : 0,
			(condition.z) ? 1 : 0,
			(condition.w) ? 1 : 0
			);
}

GBuffer Run(PixelShaderInput Input)
{
	GBuffer values = (GBuffer)0;
	
	float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13;
	uint4 bitmask, uiDest;
	float4 fDest;

	r0.x = round(Input.WorldPos.w);
	r0.x = (uint)r0.x;
	r1.xyzw = Unique_NSC.Sample(sampler1_s, Input.TexCoords.xy).zxyw;
	r0.y = cmp(0.0250000004 >= r1.w);
	r0.y = r0.y ? 0 : 1;
	r0.zw = TextureRatio.xy * Input.TexCoords.zw;
	r2.xyzw = float4(1.5,3,2,2.70000005) * r0.zwzw;
	r3.xyzw = Texture3.Sample(sampler3_s, r2.xy).xyzw;
	r2.xy = float2(1,1) + -r3.wz;
	r4.x = saturate(r2.x * 2.85714293 + -2.14285707);
	r4.y = cmp(WSWeatherType.x >= 0);
	r4.y = r4.y ? 1.000000 : 0;
	r4.yz = saturate(WeatheringParams.zx * r4.yy);
	r4.w = 0.00999999978 + r4.y;
	r5.xyzw = MetalTiling.Sample(sampler1_s, r2.zw).xyzw;
	r2.z = 1 + -r1.x;
	r2.w = saturate(3 * r2.z);
	r6.x = saturate(r1.x + r1.x);
	r6.yz = float2(1,2) * TextureRatio.xy;
	r7.xy = Input.TexCoords.zw * r6.yz;
	r7.xy = float2(6,6) * r7.xy;
	r7.xyz = Wood_Micro.Sample(sampler3_s, r7.xy).xyz;
	r2.w = r6.x * r2.w;
	r2.w = r7.z * r2.w;
	r6.x = 0.5 * r2.w;
	r8.xyzw = cmp(float4(0,0,1,-1) >= Input.TexCoords.xyxx);
	r8.xyz = r8.xyz ? float3(1,1,1) : 0;
	r6.w = -r8.x * r8.y + 1;
	r6.w = -r6.w * r8.y + 1;
	r7.w = -r2.w * 0.5 + r5.z;
	r6.x = r6.w * r7.w + r6.x;
	r7.w = cmp(Input.TexCoords.x < 0);
	r7.w = r7.w ? 0 : 1;
	r8.y = -MetalColor2Smoothness + MetalColor1Smoothness;
	r8.y = r7.w * r8.y + MetalColor2Smoothness;
	r8.y = r8.y + -r5.z;
	r9.x = saturate(r5.w * 0.166666672 + 0.5);
	r2.w = WoodSmoothness * r2.w;
	r9.x = 1.79999995 * r9.x;
	r9.y = r9.x * r2.w;
	r8.y = 0.699999988 + r8.y;
	r9.z = r2.z * r2.z;
	r9.z = r9.z * r9.z;
	r9.w = 1 + -r5.w;
	r9.w = r9.z * r9.w + -r9.z;
	r9.z = saturate(r9.w * 0.699999988 + r9.z);
	r9.z = 1 + -r9.z;
	r2.w = -r2.w * r9.x + r8.y;
	r2.w = r6.w * r2.w + r9.y;
	r2.w = r9.z * r2.w;
	r8.y = CamoOnMetalColor1and2.y + -CamoOnMetalColor1and2.x;
	r8.x = saturate(r8.x * r8.y + CamoOnMetalColor1and2.x);
	r8.y = max(0.100000001, r5.w);
	r8.y = min(0.899999976, r8.y);
	r8.y = 1 + -r8.y;
	r10.xyzw = CamoStrength.xyzw * r8.zzzz;
	r10.xyzw = saturate(r10.xyzw * r8.yyyy);
	r10.xyzw = r10.xyzw * r8.xxxx;
	r10.xyzw = r10.xyzw * r8.zzzz;
	r10.xyzw = r8.wwww ? float4(0,0,0,0) : r10.xyzw;
	r8.x = CamoOnMetalAndWood.x + -CamoOnMetalAndWood.y;
	r8.x = r6.w * r8.x + CamoOnMetalAndWood.y;
	r11.xyzw = r10.xyzw * r8.xxxx;
	r0.zw = CamoPatternTiling.xy * r0.zw;
	r10.xyz = Camo.Sample(sampler2_s, r0.zw).xyz;
	r12.xyz = r10.xyz * r11.xyz;
	r0.z = r10.w * r8.x + r12.x;
	r0.z = r10.y * r11.y + r0.z;
	r0.z = saturate(r10.z * r11.z + r0.z);
	r0.w = 1 + -r7.z;
	r0.w = r1.x * 0.699999988 + r0.w;
	r8.x = r1.x + -r0.w;
	r0.w = r6.w * r8.x + r0.w;
	r8.xz = saturate(r0.ww * float2(5,-5) + float2(-0.25,3.75));
	r0.w = r8.x * r8.z;
	r8.w = cmp(r0.w < 0.5);
	r9.y = dot(r8.yy, r0.ww);
	r9.w = -r8.x * r8.z + 1;
	r9.w = r9.w + r9.w;
	r8.y = 1 + -r8.y;
	r8.y = -r9.w * r8.y + 1;
	r8.y = r8.w ? r9.y : r8.y;
	r8.x = -r8.x * r8.z + r8.y;
	r0.w = saturate(r8.x * 4 + r0.w);
	r0.w = max(CamoWearEdgeFill, r0.w);
	r0.z = r0.w * r0.z;
	r0.w = r0.z * r0.z;
	r8.x = r0.w * r0.w;
	r6.x = CamoSmoothness * r6.x + -r2.w;
	r2.w = r8.x * r6.x + r2.w;
	r8.xy = cmp(float2(1,2) >= Input.TexCoords.yy);
	r6.x = r8.x ? 1.000000 : 0;
	r2.w = r2.w + -r5.z;
	r2.w = r6.x * r2.w + r5.z;
	r4.w = cmp(r4.w < r4.z);
	r4.w = r4.w ? 1.000000 : 0;
	r8.x = r4.w * r3.z;
	r10.xyzw = float4(-2.79999995,0.888067603,0.932940722,0.950238824) * r8.xxxx;
	r8.x = r3.z * 3 + r10.x;
	r8.z = cmp(r3.w < 0.5);
	r8.w = dot(r3.zz, r3.ww);
	r2.x = r2.x + r2.x;
	r2.x = -r2.x * r2.y + 1;
	r2.x = r8.z ? r8.w : r2.x;
	r2.x = r2.x + -r3.w;
	r2.x = r2.x * r4.w + r3.w;
	r4.yz = float2(0.150000006,0.100000001) * r4.yz;
	r2.y = max(r4.y, r4.z);
	r2.y = -0.00100000005 + r2.y;
	r2.x = cmp(r2.y >= r2.x);
	r2.y = r2.x ? 1.000000 : 0;
	r4.y = r8.x + -r2.w;
	r2.w = r2.y * r4.y + r2.w;
	r4.y = saturate(-1 + WSWeatherType.x);
	r4.y = 1 + -r4.y;
	r4.y = WSShaderParam.x * r4.y;
	r4.z = -r4.y * 0.200000003 + 1.00100005;
	r4.z = cmp(r3.w >= r4.z);
	r4.z = r4.z ? 1.000000 : 0;
	r2.w = r4.y * r4.x + r2.w;
	r2.w = r4.z + r2.w;
	r4.x = saturate(r3.w * 10 + -5);
	r4.y = saturate(BloodParam.w);
	r4.w = -r4.y * 0.200000003 + 1;
	r3.w = -0.00100000005 + r3.w;
	r3.w = cmp(r3.w >= r4.w);
	r4.w = r3.w ? 1.000000 : 0;
	r4.x = r4.x * r3.y;
	r4.x = max(r4.w, r4.x);
	r3.w = r3.w ? -1 : -0;
	r3.w = r4.x + r3.w;
	r3.w = r4.y * r3.w + r4.w;
	r4.x = 1 + -r2.w;
	r2.w = r3.w * r4.x + r2.w;
	r4.xy = r1.wx * r1.wx;
	r4.x = min(1, r4.x);
	r2.w = r2.w * r0.y;
	
	values.Smoothness = r4.x * r2.w;
	
	r1.x = saturate(r1.x);
	r1.x = r1.x * r1.x;
	r2.w = r1.x * r1.x;
	r8.x = r2.w * r1.x;
	r5.w = dot(r8.xx, r5.ww);
	r1.x = -r1.x * r2.w + r5.w;
	r1.x = r1.x * 0.699999988 + r8.x;
	r1.x = r1.x * r8.x;
	r2.w = -MetalMetalness2 + MetalMetalness;
	r2.w = r7.w * r2.w + MetalMetalness2;
	r2.w = r1.x * 0.349999994 + r2.w;
	r2.w = r2.w + -r6.w;
	r2.w = r6.w * r2.w + r6.w;
	r5.w = r2.w * r9.z;
	r0.w = -r0.w * r0.w + 1;
	r0.w = r5.w * r0.w;
	r2.w = r2.w * r9.z + -r0.w;
	r0.w = CamouflaugeMetalness * r2.w + r0.w;
	r0.w = -0.949999988 + r0.w;
	r0.w = r6.x * r0.w + 0.949999988;
	r2.x = r2.x ? 0 : 1;
	r0.w = r2.x * r0.w;
	r0.w = r3.w * -r0.w + r0.w;
	r2.x = ADS_glowing_Intensity * ScopeCrosshairOffset.y;
	r2.w = 0.0149999997 * r2.x;
	r2.x = -r2.x * 0.75 + 1;
	r0.w = r0.w * r0.y;
	
	values.Metallic = r2.x * r0.w;
	
	r0.w = max(0, r1.x);
	r0.w = min(0.600000024, r0.w);
	r8.xzw = -MetalColor2.xyz + MetalColor1.xyz;
	r8.xzw = r7.www * r8.xzw + MetalColor2.xyz;
	r8.xzw = r8.xzw + r0.www;
	r8.xzw = r8.xzw * r5.zzz;
	r6.yz = Wood_Macro_Tiling.xy * r6.yz;
	r6.yz = Input.TexCoords.zw * r6.yz;
	r0.w = Wood_Macro.Sample(sampler3_s, r6.yz).x;
	r11.xyz = WoodColor_01_Highlight.xyz + -WoodColor_03_Lowlight.xyz;
	r11.xyz = r0.www * r11.xyz + WoodColor_03_Lowlight.xyz;
	r0.w = max(0.100000001, r2.z);
	r0.w = min(0.899999976, r0.w);
	r11.xyz = r11.xyz * r7.zzz;
	r11.xyz = r11.xyz * r0.www;
	r9.xyw = r11.xyz * r9.xxx;
	r9.xyw = r9.xyw + r9.xyw;
	r8.xzw = r8.xzw * float3(2,2,2) + -r9.xyw;
	r8.xzw = r6.www * r8.xzw + r9.xyw;
	r0.w = -r9.z * r9.z + 1;
	r9.xyz = r5.zzz * float3(0.186118007,0.158467799,0.133930206) + -r8.xzw;
	r8.xzw = r0.www * r9.xyz + r8.xzw;
	r9.xyz = CamoColor3.xyz + -r8.xzw;
	r9.xyz = r11.www * r9.xyz + r8.xzw;
	r11.xyz = CamoColor0.xyz + -r9.xyz;
	r9.xyz = r12.xxx * r11.xyz + r9.xyz;
	r11.xyz = CamoColor1.xyz + -r9.xyz;
	r9.xyz = r12.yyy * r11.xyz + r9.xyz;
	r11.xyz = CamoColor2.xyz + -r9.xyz;
	r9.xyz = saturate(r12.zzz * r11.xyz + r9.xyz);
	r0.w = r5.z + r5.z;
	r11.xyz = r8.yyy ? float3(0.456411004,0.386622995,0.212443203) : float3(0.396755308,0.274828404,0.153981194);
	r9.xyz = r0.www * r9.xyz + -r8.xzw;
	r8.xzw = r0.zzz * r9.xyz + r8.xzw;
	r9.xyz = r8.yyy ? float3(-0.456411004,-0.386622995,-0.212443203) : float3(-0.396755308,-0.274828404,-0.153981194);
	r8.xyz = r9.xyz + r8.xzw;
	r6.xyz = r6.xxx * r8.xyz + r11.xyz;
	r8.xyz = r3.zzz * float3(0.111932397,0.0670593008,0.0497611985) + r10.yzw;
	r8.xyz = r8.xyz + -r6.xyz;
	r6.xyz = r2.yyy * r8.xyz + r6.xyz;
	r8.xyz = float3(0.0781873986,0.00575789995,0.00865249988) + -r6.xyz;
	r6.xyz = r3.www * r8.xyz + r6.xyz;
	r6.xyz = r6.xyz * r0.yyy;
	
	values.BaseColor = r6.xyz * r1.www;
	
	r0.y = r4.x * r0.y;
	
	values.Reflectance = 0.5 * r0.y;
	
	r0.yz = r7.xy * r1.yz;
	r0.yz = r0.yz * float2(2,2) + -r1.yz;
	r0.yz = r0.yz * WoodDetailNormalIntensity + r1.yz;
	r1.xy = r1.yz + -r0.yz;
	r0.yz = r6.ww * r1.xy + r0.yz;
	r0.yz = r0.yz * r5.xy;
	r1.xy = r0.yz + r0.yz;
	r0.yz = -r0.yz * float2(2,2) + r3.xy;
	r0.yz = r2.yy * r0.yz + r1.xy;
	r1.xy = r3.xy + -r0.yz;
	r0.yz = r4.zz * r1.xy + r0.yz;
	r1.xy = r3.xy + -r0.yz;
	r0.yz = r4.ww * r1.xy + r0.yz;
	r1.xy = r0.yz * float2(2,2) + float2(-1,-1);
	r0.y = dot(r1.xy, r1.xy);
	r0.y = 1 + -r0.y;
	r0.y = max(0, r0.y);
	r1.z = sqrt(r0.y);
	r2.x = dot(r1.xyz, Input.Tangent.xyz);
	r2.y = dot(r1.xyz, Input.Binormal.xyz);
	r2.z = dot(r1.xyz, Input.Normal.xyz);
	r0.y = dot(r2.xyz, r2.xyz);
	r0.y = rsqrt(r0.y);
	r1.xyz = r2.xyz * r0.yyy;
	r3.xyzw = lightProbe[0].xyzw;
	r6.xyzw = lightProbe[1].xyzw;
	r7.xyzw = lightProbe[2].xyzw;
	r8.xyzw = lightProbe[3].xyzw;
	r0.yzw = lightProbe[4].xyz;
	r2.xyz = lightProbe[5].xyz;
	r9.xyz = lightProbe[6].xyz;
	r10.xyw = lightProbe[7].xyz;
	r5.xyz = lightProbe[8].xyz;
	r11.x = r0.y;
	r11.y = r2.x;
	r11.z = r9.x;
	r11.w = r10.x;
	r0.x = dot(r11.xyzw, r11.xyzw);
	r0.x = cmp(r0.x == 0.000000);
	r11.yzw = cmp(r5.xyz == float3(0,0,0));
	r0.x = r0.x ? r11.y : 0;
	if (r0.x != 0) {
	r12.x = r6.x;
	r12.y = r7.x;
	r12.z = r8.x;
	r4.z = dot(r12.xyz, r12.xyz);
	r4.w = sqrt(r4.z);
	r5.w = cmp(r4.w == 0.000000);
	if (r5.w != 0) {
	  r13.x = r3.x;
	} else {
	  r4.z = rsqrt(r4.z);
	  r12.xyz = r12.xyz * r4.zzz;
	  r4.z = dot(r1.xyz, r12.xyz);
	  r4.z = 1 + r4.z;
	  r4.z = 0.5 * r4.z;
	  r5.w = r4.z * r4.z;
	  r9.w = r4.w + r4.w;
	  r4.w = r4.w + r3.x;
	  r4.w = r9.w / r4.w;
	  r4.w = r4.w * r3.x;
	  r4.z = dot(r5.ww, r4.zz);
	  r4.z = -r5.w * r5.w + r4.z;
	  r4.z = r4.z * 3.33333325 + -1;
	  r13.x = r4.w * r4.z + r3.x;
	}
	}
	if (r0.x == 0) {
	r4.zw = r1.zy * r1.zy;
	r0.x = r1.x * r1.x + -r4.z;
	r4.z = r4.w * r11.x;
	r4.z = 3 * r4.z;
	r0.x = r5.x * r0.x + r4.z;
	r0.x = r0.x + r3.x;
	r0.x = r0.x + -r0.y;
	r0.y = r2.x * r1.x;
	r2.x = r9.x * r1.y;
	r2.x = r2.x * r1.z;
	r0.y = r0.y * r1.y + r2.x;
	r2.x = r10.x * r1.x;
	r0.y = r2.x * r1.z + r0.y;
	r0.x = r0.x + r0.y;
	r0.y = r7.x * r1.y;
	r0.y = r6.x * r1.x + r0.y;
	r0.y = r8.x * r1.z + r0.y;
	r13.x = r0.x + r0.y;
	}
	r12.x = r0.z;
	r12.y = r2.y;
	r12.z = r9.y;
	r12.w = r10.y;
	r0.x = dot(r12.xyzw, r12.xyzw);
	r0.x = cmp(r0.x == 0.000000);
	r0.x = r11.z ? r0.x : 0;
	if (r0.x != 0) {
	r11.x = r6.y;
	r11.y = r7.y;
	r11.z = r8.y;
	r0.y = dot(r11.xyz, r11.xyz);
	r2.x = sqrt(r0.y);
	r2.y = cmp(r2.x == 0.000000);
	if (r2.y != 0) {
	  r13.y = r3.y;
	} else {
	  r0.y = rsqrt(r0.y);
	  r11.xyz = r11.xyz * r0.yyy;
	  r0.y = dot(r1.xyz, r11.xyz);
	  r0.y = 1 + r0.y;
	  r0.y = 0.5 * r0.y;
	  r2.y = r0.y * r0.y;
	  r4.z = r2.x + r2.x;
	  r2.x = r3.y + r2.x;
	  r2.x = r4.z / r2.x;
	  r2.x = r2.x * r3.y;
	  r0.y = dot(r2.yy, r0.yy);
	  r0.y = -r2.y * r2.y + r0.y;
	  r0.y = r0.y * 3.33333325 + -1;
	  r13.y = r2.x * r0.y + r3.y;
	}
	}
	if (r0.x == 0) {
	r0.xy = r1.zy * r1.zy;
	r0.x = r1.x * r1.x + -r0.x;
	r0.y = r0.y * r0.z;
	r0.y = 3 * r0.y;
	r0.x = r5.y * r0.x + r0.y;
	r0.x = r0.x + r3.y;
	r0.x = r0.x + -r0.z;
	r0.y = r12.y * r1.x;
	r0.z = r9.y * r1.y;
	r0.z = r0.z * r1.z;
	r0.y = r0.y * r1.y + r0.z;
	r0.z = r10.y * r1.x;
	r0.y = r0.z * r1.z + r0.y;
	r0.x = r0.x + r0.y;
	r0.y = r7.y * r1.y;
	r0.y = r6.y * r1.x + r0.y;
	r0.y = r8.y * r1.z + r0.y;
	r13.y = r0.x + r0.y;
	}
	r10.x = r0.w;
	r10.y = r2.z;
	r10.z = r9.z;
	r0.x = dot(r10.xyzw, r10.xyzw);
	r0.x = cmp(r0.x == 0.000000);
	r0.x = r11.w ? r0.x : 0;
	if (r0.x != 0) {
	r8.x = r6.z;
	r8.y = r7.z;
	r0.y = dot(r8.xyz, r8.xyz);
	r0.z = sqrt(r0.y);
	r2.x = cmp(r0.z == 0.000000);
	if (r2.x != 0) {
	  r13.z = r3.z;
	} else {
	  r0.y = rsqrt(r0.y);
	  r5.xyw = r8.xyz * r0.yyy;
	  r0.y = dot(r1.xyz, r5.xyw);
	  r0.y = 1 + r0.y;
	  r0.y = 0.5 * r0.y;
	  r2.x = r0.y * r0.y;
	  r2.y = r0.z + r0.z;
	  r0.z = r3.z + r0.z;
	  r0.z = r2.y / r0.z;
	  r0.z = r0.z * r3.z;
	  r0.y = dot(r2.xx, r0.yy);
	  r0.y = -r2.x * r2.x + r0.y;
	  r0.y = r0.y * 3.33333325 + -1;
	  r13.z = r0.z * r0.y + r3.z;
	}
	}
	if (r0.x == 0) {
	r0.xy = r1.zy * r1.zy;
	r0.x = r1.x * r1.x + -r0.x;
	r0.y = r0.y * r0.w;
	r0.y = 3 * r0.y;
	r0.x = r5.z * r0.x + r0.y;
	r0.x = r0.x + r3.z;
	r0.x = r0.x + -r0.w;
	r0.y = r2.z * r1.x;
	r0.z = r10.z * r1.y;
	r0.z = r0.z * r1.z;
	r0.y = r0.y * r1.y + r0.z;
	r0.z = r10.w * r1.x;
	r0.y = r0.z * r1.z + r0.y;
	r0.x = r0.x + r0.y;
	r0.y = r7.z * r1.y;
	r0.y = r6.z * r1.x + r0.y;
	r0.y = r8.z * r1.z + r0.y;
	r13.z = r0.x + r0.y;
	}
	r0.xyz = max(float3(0,0,0), r13.xyz);
	r1.w = 1;
	r3.x = r6.w;
	r3.y = r7.w;
	r3.z = r8.w;
	r0.w = dot(r1.xyzw, r3.xyzw);
	
	values.MaterialAO = max(0, r0.w);
	
	r0.w = 100 * exposureMultipliers.w;
	r2.x = saturate(Input.Tangent.w);
	r2.y = saturate(Input.Binormal.w);
	r2.xy = float2(1,1) + -r2.xy;
	r3.xy = r2.xy * r2.xy;
	r3.xy = r3.xy * r3.xy;
	r2.xy = -r3.xy * r2.xy + float2(1,1);
	r1.w = cmp(0 >= r2.x);
	r2.x = r1.w ? 1.000000 : 0;
	r2.y = 1 + -r2.y;
	r2.z = OverHeatParam.y * OverHeatParam.y;
	r2.x = r2.x * r2.y;
	r2.y = r2.y * r2.z;
	r1.w = r1.w ? 0 : r2.y;
	r1.w = r2.x * OverHeatParam.x + r1.w;
	r1.w = r4.y * r1.w;
	r2.xyz = float3(1,0.0952275991,0.0295567997) * r1.www;
	r1.w = cmp(OverHeat != 0);
	r1.w = r1.w ? 1.000000 : 0;
	r2.xyz = r2.xyz * r1.www;
	r1.w = cmp(1 >= Input.Tangent.w);
	r1.w = r1.w ? 1.000000 : 0;
	r2.xyz = r2.xyz * r1.www + r2.www;
	r2.xyz = r2.xyz * r0.www;
	r0.xyz = r0.xyz * r4.xxx + r2.xyz;

	//o3.xyz = exposureMultipliers.xxx * r0.xyz;
	//r0.x = normalBasisCubemapTexture.Sample(sampler0_s, r1.xyz).x;
	//r0.x = 255.490005 * r0.x;
	//r0.x = (uint)r0.x;
	//r0.y = (int)r0.x * 3;
	//r0.zw = normalBasisTransforms[r0.x]._m01_m11 * r1.yy;
	//r0.zw = normalBasisTransforms[r0.x]._m00_m10 * r1.xx + r0.zw;
	//r0.yz = normalBasisTransforms[r0.x]._m02_m12 * r1.zz + r0.zw;

	values.WorldNormals = r1.xyz;
	values.Radiosity = r0.xyz;
	
	return values;
}

GBuffer GetPixelShaderIntermediates(PixelShaderInput Input)
{
	return Run(Input);
}