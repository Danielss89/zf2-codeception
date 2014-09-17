<?php

namespace Tests\Acceptance;

use \AcceptanceTester;

class UserCest
{
    public function _before(AcceptanceTester $I)
    {
    }

    public function _after(AcceptanceTester $I)
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

}
