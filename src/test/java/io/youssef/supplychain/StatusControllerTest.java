package io.youssef.supplychain;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class StatusControllerTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate rest;

    @Test
    void healthEndpointIsUp() {
        String body = rest.getForObject("http://localhost:" + port + "/health", String.class);
        assertThat(body).contains("UP");
    }

    @Test
    void indexReturnsServiceName() {
        String body = rest.getForObject("http://localhost:" + port + "/", String.class);
        assertThat(body).contains("supply-chain-demo");
    }
}
