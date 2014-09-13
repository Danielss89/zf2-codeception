<?php

namespace Test\Acceptance;

use \AcceptanceTester;

class UserCest
{
    public function _before()
    {
    }

    public function _after()
    {
    }

    public function testSignup(AcceptanceTester $I)
    {
        $I->wantTo('Signup and check i get signed in automaticly');

        $I->amOnPage('/user/register');
        $I->see('Register');
        $I->fillField('email', "test@zf2.com");
        $I->fillField('password', 'strong-password');
        $I->fillField('passwordVerify', 'strong-password');
        $I->click('Register');

        $I->seeCurrentUrlEquals('/user');
        $I->see('Hello, test!');
        $I->seeLink('[Sign Out]', '/user/logout');
    }

    public function testSignin(AcceptanceTester $I)
    {
        $I->wantTo('Signin');

        $I->amOnPage('/user/login');
        $I->see('Sign In');
        $I->fillField('identity', "test@test.com");
        $I->fillField('credential', 'password');
        $I->click('Sign In');

        $I->seeCurrentUrlEquals('/user');
        $I->see('Hello, test!');
        $I->seeLink('[Sign Out]', '/user/logout');
    }

    /**
     * @before testSignin
     */
    public function testSignout(AcceptanceTester $I)
    {
        $I->wantTo('Signout');

        $I->amOnPage('/user');
        $I->click('[Sign Out]');

        $I->seeCurrentUrlEquals('/user/login');
    }
}
