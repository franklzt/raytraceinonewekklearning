/*
Conver Wet stone shadertoy effect to unity3D
ShaderToy https://www.shadertoy.com/view/ldSSzV
"Wet stone" by Alexander Alekseev aka TDM - 2014
License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
Contact: tdmaav@gmail.com

reference:candycat https://blog.csdn.net/candycat1992/article/details/44039077
reference:光能蜗牛 https://www.jianshu.com/p/0dd606730177
*/

Shader "Shadertoy/ShaderWebStone" {
	Properties{
		iMouse("Mouse Pos", Vector) = (100, 100, 0, 0)
		iChannel0("iChannel0", 2D) = "white" {}
		iChannelResolution0("iChannelResolution0", Vector) = (100, 100, 0, 0)
	}

		CGINCLUDE
#include "UnityCG.cginc"   
#pragma target 3.0      

#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mat2 float2x2
#define mat3 float3x3
#define mat4 float4x4
#define iGlobalTime _Time.y
#define mod fmod
#define mix lerp
#define fract frac
#define texture2D tex2D
#define iResolution _ScreenParams
#define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

#define PI2 6.28318530718
#define pi 3.14159265358979
#define halfpi (pi * 0.5)
#define oneoverpi (1.0 / pi)

		fixed4 iMouse;
		sampler2D iChannel0;
		fixed4 iChannelResolution0;


//////////////////

#define SMOOTH
#define  NUM_STEPS  32;
#define  AO_SAMPLES  3;
#define  F_AO_SAMPLES  3.0;
#define  AO_PARAM  vec2(1.2, 3.8);
#define  AO_PARAM_X 1.2;
#define  AO_PARAM_Y 3.8;
#define  CORNER_PARAM  vec2(0.25, 40.0);
#define CORNER_PARAM_X 0.25;
#define CORNER_PARAM_Y 40.0;
#define  INV_AO_SAMPLES  1.0 / F_AO_SAMPLES;
#define  TRESHOLD  0.1;
#define  EPSILON  1e-3;
#define  LIGHT_INTENSITY  0.25;
#define  RED  vec3(1.0, 0.7, 0.7) * LIGHT_INTENSITY;
#define  ORANGE  vec3(1.0, 0.67, 0.43) * LIGHT_INTENSITY;
#define  BLUE  vec3(0.54, 0.77, 1.0) * LIGHT_INTENSITY;
#define  WHITE  vec3(1.2, 1.07, 0.98) * LIGHT_INTENSITY;
#define  DISPLACEMENT  0.1;
#define  iTime _Time.y;

// math
		mat3 fromEuler(vec3 ang) {
			vec2 a1 = vec2(sin(ang.x), cos(ang.x));
			vec2 a2 = vec2(sin(ang.y), cos(ang.y));
			vec2 a3 = vec2(sin(ang.z), cos(ang.z));
			mat3 m;
			m[0] = vec3(a1.y*a3.y + a1.x*a2.x*a3.x, a1.y*a2.x*a3.x + a3.y*a1.x, -a2.y*a3.x);
			m[1] = vec3(-a2.y*a1.x, a1.y*a2.y, a2.x);
			m[2] = vec3(a3.y*a1.x*a2.x + a1.y*a3.x, a1.x*a3.x - a1.y*a3.y*a2.x, a2.y*a3.y);
			return m;
		}

		float hash11(float p) {
			return fract(sin(p * 727.1)*435.545);
		}
		float hash12(vec2 p) {
			float h = dot(p, vec2(127.1, 311.7));
			return fract(sin(h)*437.545);
		}
		vec3 hash31(float p) {
			vec3 h = vec3(127.231, 491.7, 718.423) * p;
			return fract(sin(h)*435.543);
		}

		// 3d noise
		float noise_3(in vec3 p) {
			vec3 i = floor(p);
			vec3 f = fract(p);
			vec3 u = f * f*(3.0 - 2.0*f);

			vec2 ii = i.xy + i.z * vec2(5.0,5.0);
			float a = hash12(ii + vec2(0.0, 0.0));
			float b = hash12(ii + vec2(1.0, 0.0));
			float c = hash12(ii + vec2(0.0, 1.0));
			float d = hash12(ii + vec2(1.0, 1.0));
			float v1 = mix(mix(a, b, u.x), mix(c, d, u.x), u.y);

			ii += vec2(5.0,5.0);
			a = hash12(ii + vec2(0.0, 0.0));
			b = hash12(ii + vec2(1.0, 0.0));
			c = hash12(ii + vec2(0.0, 1.0));
			d = hash12(ii + vec2(1.0, 1.0));
			float v2 = mix(mix(a, b, u.x), mix(c, d, u.x), u.y);

			return max(mix(v1, v2, u.z), 0.0);
		}

		// fBm
		float fbm3(vec3 p, float a, float f) {
			return noise_3(p);
		}

		float fbm3_high(vec3 p, float a, float f) {
			float ret = 0.0;
			float amp = 1.0;
			float frq = 1.0;
			for (int i = 0; i < 4; i++) {
				float n = pow(noise_3(p * frq), 2.0);
				ret += n * amp;
				frq *= f;
				amp *= a * (pow(n, 0.2));
			}
			return ret;
		}

		// lighting
		float diffuse(vec3 n, vec3 l, float p) { return pow(max(dot(n, l), 0.0), p); }
		float specular(vec3 n, vec3 l, vec3 e, float s) {
			float nrm = (s + 8.0) / (3.1415 * 8.0);
			return pow(max(dot(reflect(e, n), l), 0.0), s) * nrm;
		}

		// distance functions
		float plane(vec3 gp, vec4 p) {
			return dot(p.xyz, gp + p.xyz*p.w);
		}
		float sphere(vec3 p, float r) {
			return length(p) - r;
		}
		float capsule(vec3 p, float r, float h) {
			p.y -= clamp(p.y, -h, h);
			return length(p) - r;
		}
		float cylinder(vec3 p, float r, float h) {
			return max(abs(p.y / h), capsule(p, r, h));
		}
		float box(vec3 p, vec3 s) {
			p = abs(p) - s;
			return max(max(p.x, p.y), p.z);
		}
		float rbox(vec3 p, vec3 s) {
			p = abs(p) - s;
			return length(p - min(p, 0.0));
		}
		float quad(vec3 p, vec2 s) {
			p = abs(p) - vec3(s.x, 0.0, s.y);
			return max(max(p.x, p.y), p.z);
		}

		// boolean operations
		float boolUnion(float a, float b) { return min(a, b); }
		float boolIntersect(float a, float b) { return max(a, b); }
		float boolSub(float a, float b) { return max(a, -b); }

		// smooth operations. thanks to iq
		float boolSmoothIntersect(float a, float b, float k) {
			float h = clamp(0.5 + 0.5*(b - a) / k, 0.0, 1.0);
			return mix(a, b, h) + k * h*(1.0 - h);
		}
		float boolSmoothSub(float a, float b, float k) {
			return boolSmoothIntersect(a, -b, k);
		}

		// world
		float rock(vec3 p) {
			float d = sphere(p, 1.0);
			for (int i = 0; i < 9; i++) {
				float ii = float(i);
				float r = 2.5 + hash11(ii);
				vec3 v = normalize(hash31(ii) * 2.0 - 1.0);
#ifdef SMOOTH
				d = boolSmoothSub(d, sphere(p + v * r, r * 0.8), 0.03);
#else
				d = boolSub(d, sphere(p + v * r, r * 0.8));
#endif        
			}
			return d;
		}

		/*float map(vec3 p) {
			float d = rock(p) + fbm3(p*4.0, 0.4, 2.96) * DISPLACEMENT;
			d = boolUnion(d, plane(p, vec4(0.0, 1.0, 0.0, 1.0)));
			return d;
		}*/

		float map(vec3 p) {
			float d = rock(p) + fbm3(p*4.0, 0.4, 2.96) * DISPLACEMENT;
			d = boolUnion(d, plane(p, vec4(0.0, 1.0, 0.0, 1.0)));
			return d;
		}

		float map_detailed(vec3 p) {
			float d = rock(p) + fbm3_high(p*4.0, 0.4, 2.96) * DISPLACEMENT;
			d = boolUnion(d, plane(p, vec4(0.0, 1.0, 0.0, 1.0)));
			return d;
		}

		// tracing
		vec3 getNormal(vec3 p, float dens) {
			vec3 n = vec3(0.0,0.0,0.0);
			float ex = p.x + EPSILON;
			float ey = p.y + EPSILON;
			float ez = p.z + EPSILON;

			vec3 vx = vec3(ex, p.y, p.z);
			vec3 vy = vec3(p.x, ey, p.z);
			vec3 vz = vec3(p.x, p.y, ez);

			n.x = map_detailed(vx);
			n.y = map_detailed(vy);
			n.z = map_detailed(vz);	
			return normalize(n - map_detailed(p));
		}

		vec2 getOcclusion(vec3 p, vec3 n) {
			vec2 r = vec2(0.0,0.0);
			for (int i = 0; i < 3; i++) {
				float f = float(i)*INV_AO_SAMPLES;
				float hao = 0.01 + f * AO_PARAM_X;
				float hc = 0.01 + f * CORNER_PARAM_X;
				float dao = map(p + n * hao) - TRESHOLD;
				float dc = map(p - n * hc) - TRESHOLD;
				r.x += clamp(hao - dao, 0.0, 1.0) * (1.0 - f);
				r.y += clamp(hc + dc, 0.0, 1.0) * (1.0 - f);
			}

			float conp = 1 / 3 * 3.8;
			float rxvalue = r.x;
			float rx = 1.0 - rxvalue * conp;
			float rclamp = clamp(rx, 0.0, 1.0);
			r.x = pow(rclamp,0.5);
			r.y = clamp(r.y*1/3*40, 0.0, 1.0);
			return r;
		}

		vec2 spheretracing(vec3 ori, vec3 dir, out vec3 p) {
			vec2 td = vec2(0.0,0.0);
			for (int i = 0; i < 32; i++) {
				p = ori + dir * td.x;
				td.y = map(p);
				if (td.y < 0.1) break;
				td.x += (td.y - 0.1) * 0.9;
			}
			return td;
		}

		//vec3 stonewhite = vec3(1.2, 1.07, 0.98) * 0.25;
		// stone
		// stone
		vec3 getStoneColor(vec3 p, float c, vec3 l, vec3 n, vec3 e) {

			vec3 stonewhite = vec3(1.2, 1.07, 0.98) * 0.25;

			c = min(c + pow(noise_3(vec3(p.x*20.0, 0.0, p.z*20.0)), 70.0) * 8.0, 1.0);
			float mc = 1.0 - c;
			float ic = pow(1.0 - mc, 0.5);
			vec3 base = vec3(0.42, 0.3, 0.2) * 0.6;
			vec3 sand = vec3(0.51, 0.41, 0.32);
			vec3 color = mix(base, sand, c);

			float f = pow(1.0 - max(dot(n, -e), 0.0), 1.5) * 0.75 * ic;
			color = mix(color, vec3(1.0,1.0,1.0), f);
			color += vec3(diffuse(n, l, 0.5) * stonewhite);
			color += vec3(specular(n, l, e, 8.0) * stonewhite * 1.5 * ic);
			n = normalize(n - normalize(p) * 0.4);
			color += vec3(specular(n, l, e, 80.0) * stonewhite * 1.5 * ic);
			return color;
		}


		// main
		vec4 mainImage(in vec2 fragCoord) {
			vec2 iuv = fragCoord.xy / iResolution.xy * 2.0 - vec2(1.0,1.0);
			vec2 uv = iuv;
			float uvrate = iResolution.x / iResolution.y;
			uv.x = uvrate * uv.x;
			float time = _Time.y * 0.3;

			// ray
			vec3 ang = vec3(0.0, 0.2, time);
			if (iMouse.z > 0.0) ang = vec3(0.0, clamp(2.0 - iMouse.y*0.01, 0.0, 3.1415), iMouse.x*0.01);
			mat3 rot = fromEuler(ang);

			vec3 ori = vec3(0.0, 0.0, 2.8);			
			vec3 dir = normalize(vec3(uv.xy, -2.0));
			ori = mul(ori, rot);
			dir = mul(dir, rot);

			// tracing
			vec3 p;
			vec2 td = spheretracing(ori, dir, p);
			vec3 n = getNormal(p, td.y);
			vec2 occ = getOcclusion(p, n);
			vec3 light = normalize(vec3(0.0, 1.0, 0.0));

			// color
			vec3 color = vec3(1.0,1.0,1.0);
			if (td.x < 3.5 && p.y > -0.89) color = getStoneColor(p, occ.y, light, n, dir);
			color *= occ.x;

			// post
			float vgn = smoothstep(1.2, 0.7, abs(iuv.y)) * smoothstep(1.1, 0.8, abs(iuv.x));
			color *= 1.0 - (1.0 - vgn) * 0.15;
			return vec4(color, 1.0);

		}

////////////////////////////////////

		struct v2f {
			float4 pos : SV_POSITION;
			float4 scrPos : TEXCOORD0;
		};

		v2f vert(appdata_base v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.scrPos = ComputeScreenPos(o.pos);
			return o;
		}

		vec4 main(vec2 fragCoord);

		fixed4 frag(v2f _iParam) : COLOR0{
			vec2 fragCoord = gl_FragCoord;
			return main(gl_FragCoord);
		}

			vec4 main(vec2 fragCoord) {
			vec2 viewPortCoor = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);// (0,0) - (1,1) 中心位置为(0.5,0.5)
			return mainImage(fragCoord);
		}

		ENDCG

			SubShader{
				Pass {
					CGPROGRAM

					#pragma vertex vert    
					#pragma fragment frag    
					#pragma fragmentoption ARB_precision_hint_fastest     

					ENDCG
				}
		}
			FallBack Off
}