/***************************************************************************
Copyright (c) 2014 King_Hual

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
************************* preprocessor definitions ************************/

#define MAX_WEATHER_INFO 7
#define REFRESH_RATE 600000

#define JSON_DEFAULT_DELIMITER '.'

#define disable_bit(%0,%1) %0&=~(1<<%1)
#define enable_bit(%0,%1) %0|=1<<%1
#define get_bit(%0,%1) (%0&(1<<%1))>>%1


/******************************** inclusion *******************************/

#include <a_samp>
#include <a_json>
#include <a_http>


/************************** forward declarations **************************/

forward Weather_Callback(index, response_code, data[]);
forward Weather_Timer();


/************************* variable declarations **************************/

new weather_info[][MAX_WEATHER_INFO] =
{
	{0, 0, 0, 0, 0, 0, 0},
	{1, 0, 0, 0, 0, 0, 0},
	{1, 1, 0, 0, 0, 0, 0},
	{-1,-1,-1,1, 0, 0, 0},
	{-1,-1,-1,0, 1, 0, 0},
	{-1,-1,-1,-1,-1,-1,1},
	{-1,-1,1, 0, 0, 0, 0},
	{-1,-1,-1,-1,0, 1,-1}
};

new weathers[][] =
{
	{7,12,15,13, 0, 6, 2,17},
	{5,10,10,10, 1,14, 3,18},
	{3, 4, 4, 7, 7, 7, 5, 5},
	{1, 8},
	{1, 9},
	{1, 11},
	{1, 16},
	{1, 19}
};

new WeatherData:weather_data_cache;
new WeatherPrefix[256] = "api.openweathermap.org/data/2.5/weather?units=metric&q=";


/*************************** stock declarations ***************************/

stock RequestWeatherData(const country[])
{
	strins(WeatherPrefix, country, 55);
	printf(WeatherPrefix);
	HTTP(0, HTTP_GET, WeatherPrefix, "", "Weather_Callback");
}

stock WeatherData:GetWeatherData(JSONNode:root, temp = 0x7FFF)
{
	new result = 0;
	new JSONArray:weather_array = json_get_array(root, "weather");
	temp = (temp == 0x7FFF ? floatround(json_get_float(root, "main.temp")) : (temp));

	for(new i=0;i<json_array_count(weather_array);++i)
	{
	    new JSONNode:array_node = json_array_at(weather_array, i);
		new weather_id = json_get_int(array_node, "id");

		switch(weather_id)
		{
		    case 800:
		    {
		        disable_bit(result, 0);
		    }
		    case 801,802:
		    {
		        enable_bit(result, 0);
		        disable_bit(result, 1);
		    }
		    case 803,804:
		    {
      			enable_bit(result, 0);
		        enable_bit(result, 1);
		    }
		    case 300..321,500..513,906:
		    {
		    	enable_bit(result, 2);
		    }
		    case 200..232,901,902,960,961:
		    {
		    	enable_bit(result, 3);
		    }
			case 701,711,721,741,771:
			{
				enable_bit(result, 4);
			}
			case 731,751,761,762:
			{
			    enable_bit(result, 5);
			}
		}
	}

	if(temp >= 30)
	    enable_bit(result, 6);

	return WeatherData:result;
}

stock MatchWeather(WeatherData:num, temp)
{
	for(new i=0;i<sizeof(weather_info);++i)
	{
	    new bool:matches = true;
	    
	    for(new j=0;j<MAX_WEATHER_INFO;++j)
	    {
	        if(weather_info[i][j] != -1 && weather_info[i][j] != get_bit(_:num, j))
			{
				matches = false;
			    break;
			}
	    }
	    
	    if(matches)
	    {
	        new ratio = temp/4;

			if(ratio < 0)
			    return weathers[i][1];
			else if(ratio > weathers[i][0])
			    return weathers[i][weathers[i][0]];
			else
			    return weathers[i][ratio+1];
	    }
	}
	
	return -1;
}

stock SetWeatherFromData(WeatherData:data, temp)
{
	if(data != weather_data_cache && _:data >= 0)
	{
	    new id = MatchWeather(data, temp);
	    
/********************************* endpoint *******************************/
	    SetWeather(id);
/******************************** /endpoint *******************************/
		
        weather_data_cache = data;
	}
}


/************************** public declarations ***************************/

public Weather_Callback(index, response_code, data[])
{
	new JSONNode:root = json_parse_string(data);
	new temp = floatround(json_get_float(root, "main.temp"));
	new WeatherData:weather_data = GetWeatherData(root, temp);
	
	json_close(root);
	SetWeatherFromData(weather_data, temp);
}

public Weather_Timer()
{
    RequestWeatherData("London,uk");
}


/****************************** entry  point ******************************/

public OnFilterScriptInit()
{

	SetTimerEx("Weather_Timer", REFRESH_RATE, 1, "");
	return 1;
}
