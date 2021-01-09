/*
# Copyright 2021 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# This program may also be used under the terms of a commercial or
# enterprise edition license of COSMOS if purchased from the
# copyright holder
*/

describe('TlmViewer', () => {
  function showScreen(target, screen) {
    cy.visit('/telemetry-viewer')
    cy.hideNav()
    cy.server()
    cy.route('POST', '/api').as('api')
    cy.chooseVSelect('Select Target', target)
    cy.chooseVSelect('Select Screen', screen)
    cy.contains('Show Screen').click()
    cy.contains(target + ' ' + screen).should('be.visible')
    cy.wait('@api').should((xhr) => {
      expect(xhr.status, 'successful POST').to.equal(200)
    })
    cy.get('.mdi-close-box').click()
    cy.contains(target + ' ' + screen).should('not.exist')
    cy.get('@consoleError').should('not.be.called')
  }

  it('displays INST ADCS', () => {
    showScreen('INST', 'ADCS')
  })
  it('displays INST ARRAY', () => {
    showScreen('INST', 'ARRAY')
  })
  it('displays INST BLOCK', () => {
    showScreen('INST', 'BLOCK')
  })
  it('displays INST COMMANDING', () => {
    showScreen('INST', 'COMMANDING')
  })
  it('displays INST GRAPHS', () => {
    showScreen('INST', 'GRAPHS')
  })
  it('displays INST GROUND', () => {
    showScreen('INST', 'GROUND')
  })
  it('displays INST HS', () => {
    showScreen('INST', 'HS')
  })
  it('displays INST LATEST', () => {
    showScreen('INST', 'LATEST')
  })
  it('displays INST LIMITS', () => {
    showScreen('INST', 'LIMITS')
  })
  it('displays INST OTHER', () => {
    showScreen('INST', 'OTHER')
  })
  it('displays INST PARAMS', () => {
    showScreen('INST', 'PARAMS')
  })
  it('displays INST TABS', () => {
    showScreen('INST', 'TABS')
  })
})
