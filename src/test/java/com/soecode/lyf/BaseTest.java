package com.soecode.lyf;

import com.soecode.lyf.config.DaoConfig;
import com.soecode.lyf.config.RootConfig;
import com.soecode.lyf.config.ServiceConfig;
import com.soecode.lyf.config.WebConfig;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

/**
 * 配置spring和junit整合，junit启动时加载springIOC容器 spring-test,junit
 */
@RunWith(SpringJUnit4ClassRunner.class)
// 告诉junit spring配置文件
@ContextConfiguration(classes = {RootConfig.class})
@TestPropertySource("classpath:jdbc.properties")
@WebAppConfiguration
public class BaseTest {

}
