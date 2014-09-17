<?php
namespace Codeception\Module;

// here you can define custom actions
// all public methods declared in helper class will be available in $I

class FunctionalHelper extends \Codeception\Module
{
    public function amSignedIn()
    {
        $application = $this->getModule('ZF2')->application;
        $serviceLocator = $application->getServiceManager();

        $authService = $serviceLocator->get('zfcuser_auth_service');

        $this->assertTrue($authService->hasIdentity());
    }

    public function amNotSignedIn()
    {
        $application = $this->getModule('ZF2')->application;
        $serviceLocator = $application->getServiceManager();

        $authService = $serviceLocator->get('zfcuser_auth_service');

        $this->assertFalse($authService->hasIdentity());
    }
}
