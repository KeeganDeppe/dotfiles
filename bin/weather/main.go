package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os/exec"
	"strings"
)

type Weather struct {
	Temp     float64
	Humidity int
	Icon     rune
}

func (w *Weather) String() string {
	return fmt.Sprintf("%c %.1f%c %d%%", w.Icon, w.Temp, '\ue341', w.Humidity) // Output as ICON ##.#*F ##% where the rune is a degree sign
}

func main() {
	weathercmd := exec.Command("sh", "-c", "${HOME}/.dotfiles/bin/weather/weather.sh")
	var out bytes.Buffer
	weathercmd.Stdout = &out
	if err := weathercmd.Run(); err != nil {
		panic(err)
	}
	// parsing json time :D
	var temp map[string]interface{}
	if err := json.Unmarshal(out.Bytes(), &temp); err != nil {
		panic(err)
	}
	// fmting hell
	weather := &Weather{}
	for k, v := range temp {
		if k == "main" {
			// weather info
			for nk, nv := range v.(map[string]interface{}) {
				if nk == "temp" {
					weather.Temp = nv.(float64)
				} else if nk == "humidity" {
					weather.Humidity = int(nv.(float64)) // this is as gross as it gets
				}
			}
		} else if k == "weather" {
			m := v.([]interface{})
			for nk, nv := range m[0].(map[string]interface{}) {
				if nk == "icon" {
					weather.Icon = getIcon(nv.(string))
				}
			}
		}
	}
	fmt.Print(weather)
}

func getIcon(code string) rune {
	weather := strings.Trim(code, "nd") // trimming day or night tag
	switch weather {
	case "01":
		// clear skys
		return '\ue30d' // sun code
	case "02", "03":
		// few clouds and scattered
		return '\ue302' // small clouds with sun
	case "04":
		// broken clouds
		return '\ue312' // big clouds with sun
	case "09", "10":
		// rain
		return '\ue318' // cloud with rain
	case "11":
		// thunderstorm
		return '\ue31d' // thunderstorm cloud
	case "13":
		// snow
		return '\ue31a' // snow cloud
	case "50":
		// mist
		return '\ue313' // fog
	default:
		return '\uFFFD' // question mark
	}
}
