Shader "Unlit/cod1-2020"
{
	Properties
	{
		_Sura ("sura", 2D) = "white" {}
		// A textura _Sura2 nunca chegava a ser usada, pelo que foi removida

		[Toggle]
		_XPlus("Valor X+", Range(0,1)) = 1
		[Toggle]
		_XMinus("Valor X-", Range(0,1)) = 1
		[Toggle]
		_YPlus("Valor Y+", Range(0,1)) = 1
		[Toggle]
		_ColorInverter("Inversão da cor", Range(0,1)) = 1
		_Clip("Valor de clip", Range(0,1)) = 0.5

	}

	SubShader
	{	
		// Embora não seja de grande relevância, podemos adicionar um 'Level Of Detail'
		LOD 100

		Cull Off
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			/* Dar o nome mais 'comum' aos vertex e fragment shaders */
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			/* Dar o nome mais 'comum' à estrutura 'a' */
			struct appdata
			{ /* O facto de serem usados halfs não alteram o produto final e têm menos peso no processamento */
				half4 p : POSITION;
				half3 n : NORMAL;
				half2 u : TEXCOORD0;
			};

			/* E também à estrutura 'b' */ 
			struct v2f
			{
				float4 p : SV_POSITION;
				half3 n : NORMAL; /* Neste caso estava a ser usado um float2 para um valor com 3 coordenadas, o que impedia o fragment shader de usar a componente z da normal */
				half2 u : TEXCOORD0; /* Para além disso, tanto a normal como os uvs podem ser halfs, diminuindo a capacidade de processamento */
			};

			sampler2D _Sura;
			/* A variável 'intrashader' também é eliminada, visto que não está a ser usada */
	
			/* Usar floats é completamente overkill para variáveis que guardam toggles. Podem ser usados fixed */
			fixed _XPlus;
			fixed _XMinus;
			fixed _YPlus;
			fixed _ColorInverter;
			fixed _Clip;

			v2f vert (appdata i)
			{
				v2f o;
				o.p = UnityObjectToClipPos(i.p);
				o.u = i.u;
				o.n = i.n;
				return o;
			}
			
			float4 frag(v2f i) : COLOR
			{
				float4 c = tex2D(_Sura, i.u);
				/* A variável 'd' nunca chegava a ser utilizada, de qualquer forma */

			    c = _XPlus == 1 ? c*  i.n.x : 
					_XMinus == 1 ? c*  -i.n.x : 
					_YPlus == 1 ? c*  i.n.y : 
					c;

				/* Era feito em 3 linhas aquilo que era passível de ser feito numa única */
				c = _ColorInverter ? 1-c : c;

				/* Em vez de existir um valor hard coded e de forma a podermos controlar o valor no inspector*/
				if(c.x > _Clip && c.y > _Clip && c.z > _Clip )
				{
					clip(-1);
				}
				/* O else é inútil, uma vez que a estrutura será retornada de qualquer forma */
				
				return c;
			}
			ENDCG
		}

		Pass
        {          
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
      
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                /* UVs e normais são inúteis neste caso, porque nunca são utilizados, ou seja, simplesmente ocupam memória */
				/* A 'tag' responsável pelo semantic binding das normais deveria aparecer em maiúsculas. */
            };

            struct v2f
            {
                /* As coordenadas de textura são passadas novamente, embora não necessárias */
                float4 vertex : SV_POSITION;
            };

      

            v2f vert (appdata v)
            {
                v2f o;
			
				v.vertex.x += _SinTime.x;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                half4 col = half4(0.2,0.3,0.5,1);

				 
				if(abs(_SinTime.a) > 0.1){
					clip(-1);
				}
                
				return col;
            }
            ENDCG
        } 
	}
}