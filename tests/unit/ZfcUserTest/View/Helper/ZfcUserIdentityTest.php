<?php

namespace ZfcUserTest\View\Helper;

use ZfcUser\View\Helper\ZfcUserIdentity;

class ZfcUserIdentityTest extends \Codeception\TestCase\Test
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    protected $helper;

    protected $authService;

    protected function _before()
    {
        $helper = new ZfcUserIdentity();
        $this->helper = $helper;

        $authService = $this->getMock('Zend\Authentication\AuthenticationService');
        $this->authService = $authService;

        $helper->setAuthService($authService);
    }

    protected function _after()
    {
    }

    public function testInvokeWithIdentity()
    {
        $user = $this->getMock('ZfcUser\Entity\User');

        $this->authService->expects($this->once())
            ->method('hasIdentity')
            ->will($this->returnValue(true));
        $this->authService->expects($this->once())
            ->method('getIdentity')
            ->will($this->returnValue($user));

        $result = $this->helper->__invoke();

        $this->assertEquals($user, $result);
    }

    /**
     * @covers ZfcUser\View\Helper\ZfcUserIdentity::__invoke
     */
    public function testInvokeWithoutIdentity()
    {
        $this->authService->expects($this->once())
            ->method('hasIdentity')
            ->will($this->returnValue(false));

        $result = $this->helper->__invoke();

        $this->assertFalse($result);
    }

}
