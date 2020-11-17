package fr.xebia.clickcount;

import javax.inject.Singleton;

@Singleton
public class Configuration {

    public final String redisHost;
    public final int redisPort;
    public final int redisConnectionTimeout;  //milliseconds

    public Configuration() {
        // TODO: Use environment variable to configure redis endpoint
        redisHost = "localhost";
        // redisHost = "redis";
        redisPort = 6379;
        redisConnectionTimeout = 2000;
    }
}
