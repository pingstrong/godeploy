package main

import "github.com/gin-gonic/gin"

func main() {
	r := gin.Default()
	gin.SetMode(gin.ReleaseMode)
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.Run("0.0.0.0:9090") // 监听并在 0.0.0.0:9090 上启动服务
}
